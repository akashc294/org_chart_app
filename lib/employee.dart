class Employee {
  int? employeeId;
  String? name;
  String? phone;
  String? email;
  String? team;
  String? reportingManager;
  int? reporting_manager_id;
  String? designation;

  Employee(
      {this.employeeId,
        this.name,
        this.phone,
        this.email,
        this.team,
        this.reportingManager,
        this.reporting_manager_id,
        this.designation});

  Employee.fromJson(Map<String, dynamic> json) {
    employeeId = json['employee_id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    team = json['team'];
    reportingManager = json['reporting_manager'];
    reporting_manager_id = json['reporting_manager_id'];
    designation = json['designation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['employee_id'] = employeeId;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['team'] = team;
    data['reporting_manager'] = reportingManager;
    data['reporting_manager_id'] = reporting_manager_id;
    data['designation'] = designation;
    return data;
  }
}
