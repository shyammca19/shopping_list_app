import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;
//as tells dart all the content provided by this package should be bundled into object this name here (http)

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false; //this is for disable buttons when data load

  void _saveItem() async {
    // //this triger all validation inside the form
    // _formKey.currentState!.validate();
    // //the onsaved function trigered
    // _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      //validate return bool so the save only trigered its true
      _formKey.currentState!.save();
      // print(_enteredName);
      // print(_enteredQuantity);
      // print(_selectedCategory);

      setState(() {
        _isSending = true;
      });

      //(url, path)...past url from firebase, path is node created in firebase it could be any any name
      //json.encode...convert data into jason format
      //inside json.encode...dont need to send id because firebase create uniq id
      final url = Uri.https('flutter-demo-46554-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title,
          },
        ),
      );

      // print(response.body);
      // print(response.statusCode);

      final Map<String, dynamic> resData = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );

      // Navigator.of(context).pop(
      //   GroceryItem(
      //       id: DateTime.now().toString(),
      //       name: _enteredName,
      //       quantity: _enteredQuantity,
      //       category: _selectedCategory),
      // ); //using this we passing data from screen to screen...in grocery_item screen the push() holds a future value
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null; //tells flutter the value is valid so return null
                },
                onSaved: (value) {
                  _enteredName = value!; //! so it cant be null
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    //because textfield inside row it gets unconstraint space so
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid, positive number.';
                        }
                        return null; //tells flutter the value is valid so return null
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(
                            value!); //tryparse retrun null, parse return error
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        //this for works in lists...here categories is a map so we use .entries it get all items in the map in the end list
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value, //we can use also key
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                //here category has key value because .entries...so we use value.
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        //this should be in setstate because the initialy it shows _selectedCategory then we select value it should appear so the _selectedcategory must update(the build method must rebuild)
                        setState(() {
                          _selectedCategory = value!;
                        });
                        //there is no need to impliment onsaved here because we already updated using setstate
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                            //the inputfields are set back to its initial value
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//form is a combination of input fields
//it helps with getting user input,validating and showing on screen validation error
//more complex input field combinations you use form
//validation is used to validate and display errors atomaticaly
