import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/point_service.dart';
import '../services/patient_service.dart';

class PatientPage extends StatefulWidget {
  const PatientPage({Key? key}) : super(key: key);

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  late List<Patient> _patients = [];
  final PointService _pointService = PointService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      _patients = await PatientService().getAll();
      setState(() {});
    } catch (e) {
      print('Error loading patients: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data pasien: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _patients = [];
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPatients =
        _patients.where((patient) {
          if (_searchQuery.toLowerCase() == 'belum diperiksa') {
            return !patient.isPemeriksaanSelesai;
          } else if (_searchQuery.toLowerCase() == 'sudah diperiksa') {
            return patient.isPemeriksaanSelesai;
          } else {
            return patient.nama.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                patient.nik.contains(_searchQuery);
          }
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pasien'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Filter Pasien'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Semua Pasien'),
                            onTap: () {
                              setState(() => _searchQuery = '');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text('Belum Diperiksa'),
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = 'belum diperiksa';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text('Sudah Diperiksa'),
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = 'sudah diperiksa';
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari pasien (nama/NIK)...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child:
                _patients.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada data pasien',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tambahkan pasien dengan tombol + di bawah',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredPatients.length,
                      itemBuilder: (c, i) {
                        final p = filteredPatients[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  p.isPemeriksaanSelesai
                                      ? Colors.green.shade100
                                      : Colors.grey.shade200,
                              child: Icon(
                                p.isPemeriksaanSelesai
                                    ? Icons.check_circle
                                    : Icons.person,
                                color:
                                    p.isPemeriksaanSelesai
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                            ),
                            title: Text(
                              p.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('NIK: ${p.nik}'),
                            trailing:
                                p.isPemeriksaanSelesai
                                    ? const Text(
                                      'Selesai',
                                      style: TextStyle(color: Colors.green),
                                    )
                                    : TextButton(
                                      onPressed: () => _togglePemeriksaan(p),
                                      child: const Text('Periksa'),
                                    ),
                            onTap: () => _showDetail(p),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPatient,
        backgroundColor: const Color(0xFF2AA89B),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _togglePemeriksaan(Patient patient) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Pemeriksaan'),
            content: Text(
              'Apakah Anda yakin ingin menandai ${patient.nama} sebagai sudah diperiksa?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    patient.isPemeriksaanSelesai = true;
                    await PatientService().update(patient);
                    _pointService.addPoints(
                      10,
                      'Pemeriksaan pasien ${patient.nama}',
                    );
                    await _loadPatients();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Berhasil menambahkan pemeriksaan',
                                    ),
                                    Text(
                                      '+10 poin (Total: ${_pointService.points} poin)',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Ya, Tandai'),
              ),
            ],
          ),
    );
  }

  void _addPatient() {
    final formKey = GlobalKey<FormState>();
    final ctrlNama = TextEditingController();
    final ctrlNik = TextEditingController();
    final ctrlUmur = TextEditingController();
    final ctrlAlamat = TextEditingController();
    final ctrlKontak = TextEditingController();
    DateTime? tanggal = DateTime.now();
    Map<String, bool> gejala = {
      for (var e in [
        'Batuk >2mgg',
        'BB turun',
        'Keringat malam',
        'Demam',
        'Kelenjar',
        'Lesu',
      ])
        e: false,
    };
    Map<String, bool> risiko = {
      for (var e in [
        'DM',
        'ODHV',
        'Lansia >60',
        'Hamil',
        'Perokok',
        'Riwayat TBC',
      ])
        e: false,
    };

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              // Konten dialog sama persis seperti sebelumnya
              return AlertDialog(
                title: const Text('Tambah Pasien'),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: ctrlNama,
                          decoration: const InputDecoration(
                            labelText: 'Nama',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Nama tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: ctrlNik,
                          decoration: const InputDecoration(
                            labelText: 'NIK',
                            prefixIcon: Icon(Icons.badge),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'NIK tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: ctrlUmur,
                          decoration: const InputDecoration(
                            labelText: 'Umur',
                            prefixIcon: Icon(Icons.cake),
                          ),
                          keyboardType: TextInputType.number,
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Umur tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: ctrlAlamat,
                          decoration: const InputDecoration(
                            labelText: 'Alamat',
                            prefixIcon: Icon(Icons.home),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Alamat tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: ctrlKontak,
                          decoration: const InputDecoration(
                            labelText: 'Kontak Serumah',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Kontak tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: tanggal ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (selectedDate != null) {
                              setStateDialog(() => tanggal = selectedDate);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tanggal == null
                                        ? 'Pilih Tanggal Investigasi'
                                        : 'Tanggal: ${tanggal!.day}/${tanggal!.month}/${tanggal!.year}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const Text(
                          'Gejala',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...gejala.keys.map(
                          (k) => CheckboxListTile(
                            title: Text(k),
                            value: gejala[k],
                            onChanged:
                                (v) => setStateDialog(() => gejala[k] = v!),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                        const Divider(),
                        const Text(
                          'Faktor Risiko',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...risiko.keys.map(
                          (k) => CheckboxListTile(
                            title: Text(k),
                            value: risiko[k],
                            onChanged:
                                (v) => setStateDialog(() => risiko[k] = v!),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate() && tanggal != null) {
                        try {
                          final newPatient = Patient(
                            nama: ctrlNama.text,
                            nik: ctrlNik.text,
                            umur: ctrlUmur.text,
                            alamat: ctrlAlamat.text,
                            kontak: ctrlKontak.text,
                            tanggal: tanggal!,
                            gejala: gejala,
                            risiko: risiko,
                          );
                          await PatientService().insert(newPatient);
                          _pointService.addPoints(
                            10,
                            'Pendaftaran pasien ${ctrlNama.text}',
                          );
                          await _loadPatients();
                          Navigator.pop(context);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Berhasil menambahkan pasien',
                                          ),
                                          Text(
                                            '+10 poin (Total: ${_pointService.points} poin)',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } else if (tanggal == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Silakan pilih tanggal investigasi'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _editPatient(Patient patientToEdit) {
    // Fungsi ini tidak berubah dari sebelumnya
    final formKey = GlobalKey<FormState>();
    final ctrlNama = TextEditingController(text: patientToEdit.nama);
    final ctrlNik = TextEditingController(text: patientToEdit.nik);
    final ctrlUmur = TextEditingController(text: patientToEdit.umur);
    final ctrlAlamat = TextEditingController(text: patientToEdit.alamat);
    final ctrlKontak = TextEditingController(text: patientToEdit.kontak);
    DateTime? tanggal = patientToEdit.tanggal;
    Map<String, bool> gejala = Map.from(patientToEdit.gejala);
    Map<String, bool> risiko = Map.from(patientToEdit.risiko);

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              // Konten dialog sama persis seperti _addPatient, hanya judul dan tombol Simpan yang berbeda
              return AlertDialog(
                title: const Text('Edit Pasien'),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: ctrlNama,
                          decoration: const InputDecoration(
                            labelText: 'Nama',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Nama tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: ctrlNik,
                          decoration: const InputDecoration(
                            labelText: 'NIK',
                            prefixIcon: Icon(Icons.badge),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'NIK tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: ctrlUmur,
                          decoration: const InputDecoration(
                            labelText: 'Umur',
                            prefixIcon: Icon(Icons.cake),
                          ),
                          keyboardType: TextInputType.number,
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Umur tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: ctrlAlamat,
                          decoration: const InputDecoration(
                            labelText: 'Alamat',
                            prefixIcon: Icon(Icons.home),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Alamat tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: ctrlKontak,
                          decoration: const InputDecoration(
                            labelText: 'Kontak Serumah',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Kontak tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: tanggal ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (selectedDate != null) {
                              setStateDialog(() => tanggal = selectedDate);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tanggal == null
                                        ? 'Pilih Tanggal Investigasi'
                                        : 'Tanggal: ${tanggal!.day}/${tanggal!.month}/${tanggal!.year}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const Text(
                          'Gejala',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...gejala.keys.map(
                          (k) => CheckboxListTile(
                            title: Text(k),
                            value: gejala[k],
                            onChanged:
                                (v) => setStateDialog(() => gejala[k] = v!),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                        const Divider(),
                        const Text(
                          'Faktor Risiko',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...risiko.keys.map(
                          (k) => CheckboxListTile(
                            title: Text(k),
                            value: risiko[k],
                            onChanged:
                                (v) => setStateDialog(() => risiko[k] = v!),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate() && tanggal != null) {
                        try {
                          final updatedPatient = Patient(
                            id: patientToEdit.id,
                            nama: ctrlNama.text,
                            nik: ctrlNik.text,
                            umur: ctrlUmur.text,
                            alamat: ctrlAlamat.text,
                            kontak: ctrlKontak.text,
                            tanggal: tanggal!,
                            gejala: gejala,
                            risiko: risiko,
                            isPemeriksaanSelesai:
                                patientToEdit.isPemeriksaanSelesai,
                          );
                          await PatientService().update(updatedPatient);
                          await _loadPatients();
                          Navigator.pop(context);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Berhasil memperbarui data pasien',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text('Simpan Perubahan'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // ===================================================================
  // == FUNGSI BARU UNTUK KONFIRMASI HAPUS ==
  // ===================================================================
  void _showDeleteConfirmation(BuildContext detailContext, Patient patient) {
    showDialog(
      context: detailContext,
      builder:
          (BuildContext confirmationContext) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: Text(
              'Anda yakin ingin menghapus data pasien ${patient.nama}? Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(confirmationContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    // Pastikan patient.id tidak null
                    if (patient.id == null) {
                      throw Exception("ID pasien tidak ditemukan.");
                    }

                    await PatientService().delete(patient.id!);

                    // Tutup dialog konfirmasi & dialog detail
                    Navigator.pop(confirmationContext);
                    Navigator.pop(detailContext);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Data pasien ${patient.nama} berhasil dihapus.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    // Muat ulang daftar pasien
                    await _loadPatients();
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(confirmationContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal menghapus data: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  // ===================================================================
  // == FUNGSI _showDetail YANG SUDAH DIMODIFIKASI DENGAN TOMBOL HAPUS ==
  // ===================================================================
  void _showDetail(Patient p) {
    showDialog(
      context: context,
      builder:
          (BuildContext detailDialogContext) => AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2AA89B),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                p.nama,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    p.isPemeriksaanSelesai
                                        ? Colors.green
                                        : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                p.isPemeriksaanSelesai
                                    ? 'Selesai'
                                    : 'Belum Diperiksa',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NIK: ${p.nik}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailItem(Icons.cake, 'Umur', p.umur),
                        _detailItem(Icons.home, 'Alamat', p.alamat),
                        _detailItem(Icons.phone, 'Kontak', p.kontak),
                        _detailItem(
                          Icons.calendar_today,
                          'Tanggal Investigasi',
                          '${p.tanggal.day}/${p.tanggal.month}/${p.tanggal.year}',
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const Text(
                          'Gejala:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              p.gejala.entries
                                  .map((e) => _buildChip(e.key, e.value))
                                  .toList(),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const Text(
                          'Faktor Risiko:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              p.risiko.entries
                                  .map((e) => _buildChip(e.key, e.value))
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // TOMBOL HAPUS BARU
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
                tooltip: 'Hapus Pasien',
                onPressed: () {
                  _showDeleteConfirmation(detailDialogContext, p);
                },
              ),
              const Spacer(), // Mendorong tombol lain ke kanan
              TextButton(
                onPressed: () {
                  Navigator.pop(detailDialogContext);
                  _editPatient(p);
                },
                child: const Text('Edit'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(detailDialogContext),
                child: const Text('Tutup'),
              ),
              if (!p.isPemeriksaanSelesai)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(detailDialogContext);
                    _togglePemeriksaan(p);
                  },
                  child: const Text('Tandai Selesai'),
                ),
            ],
          ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isActive
                ? const Color(0xFF2AA89B).withOpacity(0.1)
                : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF2AA89B) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isActive ? const Color(0xFF2AA89B) : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF2AA89B) : Colors.grey.shade600,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
