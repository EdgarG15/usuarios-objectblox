import 'package:flutter/material.dart';
import 'package:usuarios/model/user.dart';

import 'helper/object_box.dart';

late ObjectBox objectBox;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBox.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Usuarios',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Usuarios'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Stream<List<User>> streamUsers;
  TextEditingController usuario = TextEditingController();
  TextEditingController correo = TextEditingController();
  String? tusuario;
  String? tcorreo;

  @override
  void initState() {
    super.initState();

    streamUsers = objectBox.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: StreamBuilder<List<User>>(
        stream: streamUsers,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final users = snapshot.data!;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => objectBox.deleteUser(user.id),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          showModalBottomSheet(
              //isDismissible: false,
              isScrollControlled: true,
              context: context,
              builder: ((BuildContext context) {
                return Container(
                  padding: const EdgeInsets.all(25),
                  height: 600,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    //mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        autofocus: true,
                        controller: usuario,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                        ),
                      ),
                      TextFormField(
                        autofocus: true,
                        controller: correo,
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        child: const Text('Agregar'),
                        onPressed: () {
                          tusuario = usuario.text;
                          tcorreo = correo.text;
                          final user =
                              User(name: '$tusuario', email: '$tcorreo');
                          objectBox.insertUser(user);
                          usuario.clear();
                          correo.clear();
                        },
                      )
                    ],
                  ),
                );
              }));
        }),
        child: const Icon(Icons.add),
      ),
    );
  }
}
