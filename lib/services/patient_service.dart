import '../models/patient.dart';
import 'db_helper.dart';

class PatientService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Patient>> getAll() async {
    try {
      return await _dbHelper.getAllPatients();
    } catch (e) {
      print('Error in PatientService.getAll(): $e');
      rethrow;
    }
  }

  Future<Patient?> getById(int id) async {
    try {
      return await _dbHelper.getPatientById(id);
    } catch (e) {
      print('Error in PatientService.getById(): $e');
      return null;
    }
  }

  Future<int> insert(Patient patient) async {
    try {
      return await _dbHelper.insertPatient(patient);
    } catch (e) {
      print('Error in PatientService.insert(): $e');
      rethrow;
    }
  }

  Future<int> update(Patient patient) async {
    try {
      return await _dbHelper.updatePatient(patient);
    } catch (e) {
      print('Error in PatientService.update(): $e');
      rethrow;
    }
  }

  Future<int> delete(int id) async {
    try {
      return await _dbHelper.deletePatient(id);
    } catch (e) {
      print('Error in PatientService.delete(): $e');
      rethrow;
    }
  }

  Future<List<Patient>> searchPatients(String query) async {
    try {
      final allPatients = await getAll();
      if (query.isEmpty) return allPatients;

      return allPatients.where((patient) {
        return patient.nama.toLowerCase().contains(query.toLowerCase()) ||
            patient.nik.contains(query) ||
            patient.alamat.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('Error in PatientService.searchPatients(): $e');
      return [];
    }
  }

  Future<List<Patient>> getPatientsByStatus(bool isPemeriksaanSelesai) async {
    try {
      final allPatients = await getAll();
      return allPatients.where((patient) {
        return patient.isPemeriksaanSelesai == isPemeriksaanSelesai;
      }).toList();
    } catch (e) {
      print('Error in PatientService.getPatientsByStatus(): $e');
      return [];
    }
  }
}
