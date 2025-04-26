import 'package:flutter/material.dart';
import 'package:frontend/providers/medicationProvider.dart';
import 'package:frontend/reusable_widgets/drawer.dart';
import 'package:provider/provider.dart';

class PrescriptionSummary extends StatefulWidget {
  const PrescriptionSummary({super.key});

  @override
  State<PrescriptionSummary> createState() => _PrescriptionSummaryState();
}

class _PrescriptionSummaryState extends State<PrescriptionSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(76, 123, 238, 1),
        elevation: 0.0,
      ),
      drawer: const CustomDrawer(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff4b6cb7), Color(0xff182848)],
            stops: [0, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Consumer<MedicationProvider>(
                builder: (context, provider, _) {
                  return ListView.builder(
                    itemCount: provider.medicationReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = provider.medicationReminders[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              reminder.name,
                              style: const TextStyle(color: Colors.black),
                            ),
                            subtitle: Text(
                              'Date & Time: ${reminder.dateTime.toLocal()}\nDosage: ${reminder.dosage}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    provider.deleteReminder(reminder.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
