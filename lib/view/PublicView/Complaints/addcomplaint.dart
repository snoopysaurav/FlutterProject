import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:location/location.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:project/widgets/TEsts/getmap.dart';
import 'package:project/widgets/TEsts/newtry.dart';
import 'package:uuid/uuid.dart';

import '../../../Riverpod/baseDIo.dart';
import '../../../Riverpod/config.dart';

class ComplaintAddPage extends ConsumerStatefulWidget {
  const ComplaintAddPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ComplaintAddPageState();
}

class _ComplaintAddPageState extends ConsumerState<ComplaintAddPage> {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController wardCtrl = TextEditingController();
  bool isSelected = false;
  String? wardselectedvalue;
  String? categoryselectedvalue;
  String? priorityselectedvalue;

  var categoryItems = ["Water", "Road", "Health", "Electricity", "Education"];

  var priorityItems = ["Low", "Moderate", "Critical"];

  var items = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
  ];

  bool hasfile = false;
  String? FileName;
  String? tokenS;
  String? Type;
  File? filess;

  Future pickImage() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);

      if (result == null) {
        return Fluttertoast.showToast(msg: "No file selected");
      }
      File file = File(result.files.first.path!);
      setState(() {
        filess = file;
        hasfile = true;
      });
      var filename = file.path.split("/").last;

      String fileType = file.uri.toString().split(".").last;
      const guid = Uuid();
      const apiurl = "/CmsImage/UploadImageFile";
      String a = Uri.parse(MyConfig.appUrl + apiurl).toString();
      var formData = FormData.fromMap({
        'FileName': filename,
        'FileToken': guid.v4(),
        'FileType': fileType,
        'file': await MultipartFile.fromFile(file.path)
      });

      final response = await Api().post(a, data: formData);

      if (response.statusCode == 200) {
        var token = json.decode(response.data)["result"]["fileToken"];
        var message = json.decode(response.data)["result"]["message"];

        if (token != null) {
          setState(() {
            // isChoosed = true;
            FileName = filename;
            Type = fileType;
            tokenS = token;
          });
        } else {
          Fluttertoast.showToast(msg: message);
        }
      } else {}
    } catch (e) {
      print(e);
    }
  }

  uploadFile() async {
    var data = {
//   "id": 0,
      "complaintTitle": titleCtrl.value.text,
      "complaintDescription": descriptionCtrl.value.text,
      "complaintStatus": 0,
      "location": ref.watch(locationStateProvider).conl(),
//   "image": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "wardNo": wardselectedvalue,
      "complaintDate": "2023-03-11T08:23:31.034Z",
      "complaintMiti": "2079/11/28",
      "priority": 0,
      "category": categoryselectedvalue == "Water"
          ? 0
          : categoryselectedvalue == "Road"
              ? 1
              : categoryselectedvalue == "Health"
                  ? 2
                  : categoryselectedvalue == "Electricity"
                      ? 3
                      : 4,
      "imageToken": tokenS
    };

    try {
      var response = await Api().post(MyConfig.complaintupload, data: data);
      print("upload: ${response.statusCode}");
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Complaint Added Successfully");
        Navigator.pop(context);
      } else {}
    } catch (e) {
      print("Helloi: $e");
    }
    return null;
  }

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Complaint'),
        ),
        body: SingleChildScrollView(
          child: Form(
              key: formKey,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Title",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(),
                          ],
                        ),
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          hintText: "Enter Title",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(),
                          ],
                        ),
                        maxLines: 3,
                        controller: descriptionCtrl,
                        decoration: InputDecoration(
                          hintText: "Enter Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Location",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),

                              isSelected
                                  ? Row(
                                      children: [
                                        const Text(
                                          "Selected",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            ref
                                                .read(locationStateProvider
                                                    .notifier)
                                                .deletelatlong();
                                            setState(() {
                                              isSelected = false;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            child: Text(
                                              "Remove",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                            color: Colors.red,
                                          ),
                                        )
                                      ],
                                    )
                                  : InkWell(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(18.0),
                                                child: SimpleDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0)),
                                                  children: <Widget>[
                                                    Center(
                                                      child: SimpleDialogOption(
                                                          onPressed: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            MapSample()));
                                                            setState(() {
                                                              isSelected = true;
                                                            });
                                                          },
                                                          child: const Text(
                                                              'Choose on Map',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      20))),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Center(
                                                      child: SimpleDialogOption(
                                                          onPressed: () async {
                                                            var location =
                                                                Location();
                                                            var currentLocation =
                                                                await location
                                                                    .getLocation();
                                                            ref
                                                                .read(locationStateProvider
                                                                    .notifier)
                                                                .setLat(currentLocation
                                                                    .latitude!);
                                                            ref
                                                                .read(locationStateProvider
                                                                    .notifier)
                                                                .setLong(
                                                                    currentLocation
                                                                        .longitude!);
                                                            setState(() {
                                                              isSelected = true;
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          // onPressed: () => pickImageC(),
                                                          child: const Text(
                                                              'Use my current locations',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 20))
                                                          // .tr(),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                      },
                                      child: Chip(
                                        label: Text("Select Location"),
                                      ),
                                    )

                              // SizedBox(
                              //   width: 200,
                              //   child: TextFormField(
                              //     validator: FormBuilderValidators.compose(
                              //       [
                              //         FormBuilderValidators.required(),
                              //       ],
                              //     ),
                              //     controller: addressCtrl,
                              //     decoration: InputDecoration(
                              //       hintText: "Enter Location",
                              //       border: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(0),
                              //       ),
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Ward",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 150,
                                child: DropdownButtonFormField(
                                  isDense: true,
                                  decoration: InputDecoration(
                                    hintText: "Choose ward",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  value: wardselectedvalue,
                                  items: items.map((item) {
                                    return DropdownMenuItem(
                                      value: item,
                                      child: Text(item.toString(),
                                          overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      wardselectedvalue = newValue;
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      hasfile
                          ? SizedBox()
                          : InkWell(
                              onTap: () => pickImage(),
                              child: Container(
                                width: 200,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.grey)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.camera_alt,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text(
                                        "Upload Image",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      hasfile
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: SizedBox(
                                        height: 250,
                                        child: Image.file(
                                          filess!,
                                          fit: BoxFit.cover,
                                        ))),
                                SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      hasfile = false;
                                      tokenS = "";
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 2),
                                      Text("Remove",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                )
                              ],
                            )
                          : Container(),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Category",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 180,
                                child: DropdownButtonFormField(
                                  isDense: true,
                                  decoration: InputDecoration(
                                    hintText: "Choose Category",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  value: categoryselectedvalue,
                                  items: categoryItems.map((item) {
                                    return DropdownMenuItem(
                                      value: item,
                                      child: Text(item.toString(),
                                          overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      categoryselectedvalue = newValue;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     const Text(
                          //       "Priority",
                          //       style: TextStyle(
                          //         fontSize: 18,
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //     ),
                          //     const SizedBox(
                          //       height: 10,
                          //     ),
                          //     SizedBox(
                          //       width: 180,
                          //       child: DropdownButtonFormField(
                          //         isDense: true,
                          //         decoration: InputDecoration(
                          //           hintText: "Choose Priority",
                          //           border: OutlineInputBorder(
                          //             borderRadius: BorderRadius.circular(0),
                          //           ),
                          //         ),
                          //         value: priorityselectedvalue,
                          //         items: priorityItems.map((item) {
                          //           return DropdownMenuItem(
                          //             value: item,
                          //             child: Text(item.toString(),
                          //                 overflow: TextOverflow.ellipsis),
                          //           );
                          //         }).toList(),
                          //         onChanged: (String? newValue) {
                          //           setState(() {
                          //             priorityselectedvalue = newValue;
                          //           });
                          //         },
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),

                      const SizedBox(
                        height: 30,
                      ),
                      //submit elevated button
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                if (ref.watch(locationStateProvider).lat ==
                                        null ||
                                    ref.watch(locationStateProvider).long ==
                                        null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select location'),
                                    ),
                                  );
                                  return;
                                }
                                uploadFile();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 60, vertical: 18),
                              child: const Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
              )),
        ));
  }
}
