import 'package:flutter/material.dart';

typedef ConnectCallback = void Function(String ip, String port);

class IPDialog extends StatefulWidget {
  final ConnectCallback onConnect;

  const IPDialog({Key? key, required this.onConnect}) : super(key: key);

  @override
  _IPDialogState createState() => _IPDialogState();
}

class _IPDialogState extends State<IPDialog> {
  static const diagDefaultPort = "7000";
  final ipController = TextEditingController();
  final portController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Direct Connection"),
              Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          controller: ipController,
                          decoration: InputDecoration(
                              hintText: "Ej: 192.168.0.100",
                              labelText: "Server's IP")),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: portController,
                        decoration: InputDecoration(
                            hintText: "Eg: 7000", labelText: "Port"),
                      ),
                    ),
                  )
                ],
              ),
              ButtonBar(
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onConnect(
                          ipController.text,
                          portController.text.isEmpty
                              ? diagDefaultPort
                              : portController.text);
                    },
                    child: Text("Connect"),
                  ),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Cancel"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    ipController.dispose();
    portController.dispose();
  }
}
