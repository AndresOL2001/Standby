import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _DrawerHeader(),

          Container(
            padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
            child: Text(
              "Administracion", 
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500
              )
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: (){},
          ),

          ListTile(
            leading: const Icon(Icons.edit_document),
            title: const Text("Editar información de registro"),
            onTap: (){},
          ),

          ListTile(
            leading: const Icon(Icons.door_back_door),
            title: const Text("Accesos"),
            onTap: (){ Navigator.pushNamed(context, 'accesos'); },
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Info"),
            onTap: (){},
          ),

          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Ayuda"),
            onTap: (){},
          ),

          ListTile(
            leading: const Icon(Icons.map),
            title: const Text("Mapa"),
            onTap: (){ Navigator.pushNamed(context, 'mapa'); },
          ),


        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/menu-img.jpg'),
          fit: BoxFit.cover
        )
      ),
      child: Container(),
    );
  }
}