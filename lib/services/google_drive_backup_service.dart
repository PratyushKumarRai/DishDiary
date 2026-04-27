import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/step.dart';

class GoogleDriveBackupService {
  final GoogleSignInAccount? _account;

  GoogleDriveBackupService(this._account);

  Future<http.Client?> _getAuthClient() async {
    if (_account == null) return null;

    final auth = await _account!.authentication;
    if (auth.accessToken == null) return null;

    final credentials = AccessCredentials(
      AccessToken(
        'Bearer',
        auth.accessToken!,
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      null,
      ['email', 'https://www.googleapis.com/auth/drive.file'],
    );

    return authenticatedClient(http.Client(), credentials);
  }

  Future<bool> backupRecipes(List<Recipe> recipes) async {
    try {
      final client = await _getAuthClient();
      if (client == null) {
        throw Exception('Not authenticated with Google');
      }

      final driveApi = drive.DriveApi(client);

      // Create Excel file
      final excel = Excel.createExcel();
      final sheet = excel['Recipes'];

      // Add headers
      sheet.appendRow([
        TextCellValue('Recipe ID'),
        TextCellValue('Name'),
        TextCellValue('Category'),
        TextCellValue('Dish Emoji'),
        TextCellValue('Servings'),
        TextCellValue('Total Calories'),
        TextCellValue('Total Protein'),
        TextCellValue('Total Carbs'),
        TextCellValue('Total Fat'),
        TextCellValue('Created At'),
        TextCellValue('Updated At'),
        TextCellValue('Ingredients JSON'),
        TextCellValue('Steps JSON'),
        TextCellValue('Is Meal Plan Recipe'),
      ]);

      // Add recipes
      for (final recipe in recipes) {
        sheet.appendRow([
          TextCellValue(recipe.recipeId),
          TextCellValue(recipe.name),
          TextCellValue(recipe.category ?? ''),
          TextCellValue(recipe.dishEmoji ?? ''),
          TextCellValue(recipe.servings?.toString() ?? ''),
          TextCellValue(recipe.totalCalories?.toString() ?? ''),
          TextCellValue(recipe.totalProtein?.toString() ?? ''),
          TextCellValue(recipe.totalCarbs?.toString() ?? ''),
          TextCellValue(recipe.totalFat?.toString() ?? ''),
          TextCellValue(recipe.createdAt.toIso8601String()),
          TextCellValue(recipe.updatedAt.toIso8601String()),
          TextCellValue(
              jsonEncode(recipe.ingredients.map((i) => i.toJson()).toList())),
          TextCellValue(
              jsonEncode(recipe.steps.map((s) => s.toJson()).toList())),
          TextCellValue(recipe.isMealPlanRecipe.toString()),
        ]);
      }

      // Save Excel file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/dishdiary_backup.xlsx';
      final file = File(filePath);

      final excelBytes = excel.encode();
      if (excelBytes == null) {
        throw Exception('Failed to create Excel file');
      }

      await file.writeAsBytes(excelBytes);

      // Create or find backup folder
      var folderId = await _getOrCreateFolder(driveApi, 'DishDiary Backups');

      // Upload file
      final fileMetadata = drive.File()
        ..name =
            'dishdiary_recipes_${DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '')}.xlsx'
        ..mimeType =
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        ..parents = [folderId];

      await driveApi.files.create(
        fileMetadata,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
      );

      // Clean up
      await file.delete();

      return true;
    } catch (error) {
      print('Backup error: $error');
      return false;
    }
  }

  Future<List<Recipe>?> restoreRecipes(String userId) async {
    try {
      final client = await _getAuthClient();
      if (client == null) {
        throw Exception('Not authenticated with Google');
      }

      final driveApi = drive.DriveApi(client);

      // Find backup files
      final fileList = await driveApi.files.list(
        q: "name contains 'dishdiary_recipes_' and mimeType='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' and trashed=false",
        orderBy: 'createdTime desc',
        spaces: 'drive',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        throw Exception('No backup files found in Google Drive');
      }

      // Get the most recent backup
      final latestBackup = fileList.files!.first;

      // Download file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/temp_backup.xlsx';
      final file = File(filePath);

      final response = await driveApi.files.get(
        latestBackup.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final sink = file.openWrite();
      await response.stream.forEach((chunk) {
        sink.add(chunk);
      });
      await sink.close();

      // Read Excel file
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel['Recipes'];

      final recipes = <Recipe>[];

      // Skip header row (index 0)
      for (var i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        final recipeIdCell = row[0]?.value;
        if (recipeIdCell == null) continue;

        String getCellText(int index) {
          final cell = row[index]?.value;
          if (cell == null) return '';
          return cell.toString();
        }

        int? getIntCell(int index) {
          final cell = row[index]?.value;
          if (cell == null) return null;
          return int.tryParse(cell.toString());
        }

        double? getDoubleCell(int index) {
          final cell = row[index]?.value;
          if (cell == null) return null;
          return double.tryParse(cell.toString());
        }

        try {
          final ingredientsJson = jsonDecode(getCellText(11)) as List;
          final stepsJson = jsonDecode(getCellText(12)) as List;

          final ingredients = ingredientsJson
              .map((i) => Ingredient.fromJson(Map<String, dynamic>.from(i)))
              .toList();
          final steps = stepsJson
              .map((s) => RecipeStep.fromJson(Map<String, dynamic>.from(s)))
              .toList();

          final recipe = Recipe(
            recipeId: getCellText(0),
            userId: userId,
            name: getCellText(1),
            category: getCellText(2).isNotEmpty ? getCellText(2) : null,
            dishEmoji: getCellText(3).isNotEmpty ? getCellText(3) : null,
            servings: getIntCell(4),
            totalCalories: getDoubleCell(5),
            totalProtein: getDoubleCell(6),
            totalCarbs: getDoubleCell(7),
            totalFat: getDoubleCell(8),
            createdAt: DateTime.tryParse(getCellText(9)) ?? DateTime.now(),
            updatedAt: DateTime.tryParse(getCellText(10)) ?? DateTime.now(),
            ingredients: ingredients,
            steps: steps,
            isMealPlanRecipe: getCellText(13).toLowerCase() == 'true',
          );

          recipes.add(recipe);
        } catch (e) {
          print('Error parsing recipe row $i: $e');
          continue;
        }
      }

      // Clean up
      await file.delete();

      return recipes;
    } catch (error) {
      print('Restore error: $error');
      return null;
    }
  }

  Future<String> _getOrCreateFolder(
      drive.DriveApi driveApi, String folderName) async {
    // Try to find existing folder
    final fileList = await driveApi.files.list(
      q: "name='$folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      spaces: 'drive',
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      return fileList.files!.first.id!;
    }

    // Create new folder
    final folderMetadata = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder';

    final folder = await driveApi.files.create(folderMetadata);
    return folder.id!;
  }

  Future<DateTime?> getLastBackupDate() async {
    try {
      final client = await _getAuthClient();
      if (client == null) {
        print('No auth client for getLastBackupDate');
        return null;
      }

      final driveApi = drive.DriveApi(client);

      // Search for backup files by name pattern (most reliable method)
      final fileList = await driveApi.files.list(
        q: "name contains 'dishdiary_recipes_' and mimeType='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' and trashed=false",
        orderBy: 'createdTime desc',
        spaces: 'drive',
        pageSize: 1,
        $fields: 'files(id, name, createdTime, modifiedTime)',
      );

      print('Found ${fileList.files?.length ?? 0} backup files');

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final latestBackup = fileList.files!.first;
        print('Latest backup file: ${latestBackup.name}');
        print('Latest backup ID: ${latestBackup.id}');
        print('Created time: ${latestBackup.createdTime}');
        print('Modified time: ${latestBackup.modifiedTime}');

        // Use modifiedTime as it's more reliable for backups
        if (latestBackup.modifiedTime != null) {
          final modifiedDate =
              DateTime.parse(latestBackup.modifiedTime!.toIso8601String());
          print('Parsed modified date: $modifiedDate');
          return modifiedDate;
        }

        // Fallback to createdTime
        if (latestBackup.createdTime != null) {
          final createdDate =
              DateTime.parse(latestBackup.createdTime!.toIso8601String());
          print('Parsed created date: $createdDate');
          return createdDate;
        }
      }

      print('No backup files found');
      return null;
    } catch (e) {
      print('Error getting last backup date: $e');
      return null;
    }
  }
}
