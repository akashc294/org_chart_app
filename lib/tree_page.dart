import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphview/GraphView.dart';
import 'package:org_chart/employee.dart';

class TreeViewPage extends StatefulWidget {
  const TreeViewPage({super.key});

  @override
  _TreeViewPageState createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  List<Employee> employees = [];
  List<Node> nodeList = [];
  List<Edge> edgeList = [];
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Org Chart"),
          backgroundColor: Colors.blueAccent,
          actions: [
            IconButton(
                onPressed: (){
                  if(MediaQuery.of(context).orientation == Orientation.portrait)
                  {
                    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
                  }else {
                    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                  }
                },
                icon: const Icon(Icons.rotate_90_degrees_ccw)
            )
          ],
        ),
        body: !isLoading
            ? InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 0.01,
                maxScale: 5.6,
                child: GraphView(
                  graph: graph,
                  algorithm: BuchheimWalkerAlgorithm(
                      builder, TreeEdgeRenderer(builder)),
                  builder: (Node node) {
                    var employee = node.key?.value as Employee;
                    return rectangleWidget(employee);
                  },
                ))
            : const Center(child: CircularProgressIndicator()));
  }

  Random r = Random();

  Widget rectangleWidget(Employee employee) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Column(
                  children: [
                    Text(employee.name!),
                    Text(employee.phone!),
                    Text(employee.email!),
                    Text(employee.team!),
                  ],
                )
            )
        );
      },
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.blue[100]!, spreadRadius: 1),
            ],
          ),
          child: Column(
            children: [
              Text(
                '${employee.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '( ${employee.designation!.trim()} )',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          )),
    );
  }

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    buildTree();
    super.initState();
  }

  Future<void> readCSV() async {
    final rawData = await rootBundle.loadString("assets/data/AppleOrg.csv");
    List<String> rows = rawData.split("\n");
    rows.removeAt(0);
    for (var element in rows) {
      List<String> column = element.split(",");
      employees.add(Employee(
          employeeId: int.tryParse(column[0]),
          name: column[1],
          phone: column[2],
          email: column[3],
          team: column[4],
          reportingManager: column[5],
          reporting_manager_id: int.tryParse(column[6]),
          designation: column[7]));
    }
  }

  createNodes() {
    for (var element in employees) {
      if (element.employeeId != null) {
        nodeList.add(Node.Id(element));
      }
    }
    graph.addNodes(nodeList);
  }

  createEdges() {
    for (int i = 0; i < nodeList.length; i++) {
      int index = employees.indexWhere((nodeElement) =>
          employees[i].reporting_manager_id == nodeElement.employeeId);
      if (index < 0) {
        graph.addEdge(nodeList[0], nodeList[1],
            paint: Paint()..color = Colors.blue);
      } else {
        graph.addEdge(nodeList.elementAt(index), nodeList[i],
            paint: Paint()..color = Colors.blue);
      }
    }
  }

  buildTree() async {
    // read employee data from csv
    await readCSV();

    // creating nodes
    createNodes();

    //creating edges on the bases of reporting manager
    createEdges();

    int orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT;
    if (getWith() > getHeight()) {
      orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
    }
    builder
      ..siblingSeparation = (50)
      ..levelSeparation = (50)
      ..subtreeSeparation = (50)
      ..orientation = (orientation);

    setState(() {
      isLoading = false;
    });
  }

  getWith() {
    return MediaQuery.of(context).size.width;
  }

  getHeight() {
    return MediaQuery.of(context).size.height;
  }
}
