import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Province {
  final int id;
  final String nameTh;
  final String nameEn;
  final int geographyId;

  Province({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.geographyId,
  });
}

class District {
  final int id;
  final String nameTh;
  final String nameEn;
  final int provinceId;

  District({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.provinceId,
  });
}

class SubDistrict {
  final int id;
  final int zipCode;
  final String nameTh;
  final String nameEn;
  final int amphureId;

  SubDistrict({
    required this.id,
    required this.zipCode,
    required this.nameTh,
    required this.nameEn,
    required this.amphureId,
  });
}

class ProvincePage extends StatefulWidget {
  @override
  _ProvincePageState createState() => _ProvincePageState();
}

class _ProvincePageState extends State<ProvincePage> {
  List<Province> _provinces = [];
  List<Province> _filteredProvinces = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProvinces('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadProvinces(String searchText) async {
    final String provincesData =
        await rootBundle.loadString('assets/thai_provinces.json');
    final List<dynamic> provincesJson = json.decode(provincesData)['RECORDS'];
    _provinces = provincesJson
        .map((json) => Province(
              id: json['id'],
              nameTh: json['name_th'],
              nameEn: json['name_en'],
              geographyId: json['geography_id'],
            ))
        .toList();

    if (searchText.isEmpty) {
      _filteredProvinces = _provinces;
    } else {
      _filteredProvinces = _provinces
          .where((province) =>
              province.nameTh
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) ||
              province.nameEn.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provinces'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => loadProvinces(value),
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProvinces.length,
              itemBuilder: (context, index) {
                final province = _filteredProvinces[index];
                return ListTile(
                  title: Text(province.nameTh),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DistrictPage(province: province),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DistrictPage extends StatefulWidget {
  final Province province;

  DistrictPage({required this.province});

  @override
  _DistrictPageState createState() => _DistrictPageState();
}

class _DistrictPageState extends State<DistrictPage> {
  List<District> _districts = [];
  List<District> _filteredDistricts = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDistricts('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadDistricts(String searchText) async {
    final String amphuresData =
        await rootBundle.loadString('assets/thai_amphures.json');
    final List<dynamic> amphuresJson = json.decode(amphuresData)['RECORDS'];
    _districts = amphuresJson
        .map((json) => District(
              id: json['id'],
              nameTh: json['name_th'],
              nameEn: json['name_en'],
              provinceId: json['province_id'],
            ))
        .where((district) =>
            district.provinceId == widget.province.id &&
            (district.nameTh.toLowerCase().contains(searchText.toLowerCase()) ||
                district.nameEn
                    .toLowerCase()
                    .contains(searchText.toLowerCase())))
        .toList();

    setState(() {
      if (searchText.isEmpty) {
        _filteredDistricts = _districts;
      } else {
        _filteredDistricts = _districts
            .where((district) =>
                district.nameTh
                    .toLowerCase()
                    .contains(searchText.toLowerCase()) ||
                district.nameEn
                    .toLowerCase()
                    .contains(searchText.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Districts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => loadDistricts(value),
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDistricts.length,
              itemBuilder: (context, index) {
                final district = _filteredDistricts[index];
                return ListTile(
                  title: Text(district.nameTh),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SubDistrictPage(district: district),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SubDistrictPage extends StatelessWidget {
  final District district;

  SubDistrictPage({required this.district});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sub-districts - ${district.nameTh}'),
      ),
      body: FutureBuilder<List<SubDistrict>>(
        future: loadSubDistricts(district.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final subDistricts = snapshot.data!;
            return ListView.builder(
              itemCount: subDistricts.length,
              itemBuilder: (context, index) {
                final subDistrict = subDistricts[index];
                return ListTile(
                  title: Text(subDistrict.nameTh),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading sub-districts'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<List<SubDistrict>> loadSubDistricts(int districtId) async {
    final String subDistrictsData =
        await rootBundle.loadString('assets/thai_tambons.json');
    final List<dynamic> subDistrictsJson =
        json.decode(subDistrictsData)['RECORDS'];
    final List<SubDistrict> subDistricts = subDistrictsJson
        .map((json) => SubDistrict(
              id: json['id'],
              zipCode: json['zip_code'],
              nameTh: json['name_th'],
              nameEn: json['name_en'],
              amphureId: json['amphure_id'],
            ))
        .where((subDistrict) => subDistrict.amphureId == districtId)
        .toList();
    return subDistricts;
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thailand Data',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProvincePage(),
    );
  }
}
