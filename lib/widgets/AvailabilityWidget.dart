import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/SeekerProfile.dart';

class AvailabilityWidget extends StatefulWidget {
  final List<AvailabilitySlot> initialSlots;
  final Function(List<AvailabilitySlot>) onSlotsUpdated;

  const AvailabilityWidget(
      {Key? key, required this.initialSlots, required this.onSlotsUpdated})
      : super(key: key);

  @override
  State<AvailabilityWidget> createState() => _AvailabilityWidgetState();
}

class _AvailabilityWidgetState extends State<AvailabilityWidget> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late List<AvailabilitySlot> _slots;

  @override
  void initState() {
    super.initState();
    //Fetch  send data from Main page  when start
    _slots = List.from(widget.initialSlots);
  }

  void _addSlot() {
    if (_selectedDate == null || _selectedTime == null) return;
    setState(() {
      _slots.add(AvailabilitySlot(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        time: _selectedTime!.format(context),
      ));
      _selectedDate = null;
      _selectedTime = null;
    });
    widget.onSlotsUpdated(_slots);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildPicker(
                    label: 'DATE',
                    val: _selectedDate == null
                        ? 'mm/dd/yyyy'
                        : DateFormat('MM/dd/yyyy').format(_selectedDate!),
                    icon: Icons.calendar_today,
                    onTap: _pickDate)),
            const SizedBox(width: 10),
            Expanded(
                child: _buildPicker(
                    label: 'TIME',
                    val: _selectedTime == null
                        ? '--:-- --'
                        : _selectedTime!.format(context),
                    icon: Icons.access_time,
                    onTap: _pickTime)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addSlot,
            icon: const Icon(Icons.add, color: Colors.white),
            label:
                const Text('Add Slot', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ),
        const Divider(height: 30),
        ..._slots
            .asMap()
            .entries
            .map((entry) => _buildSlotItem(entry.key, entry.value))
            .toList(),
      ],
    );
  }

  Widget _buildPicker(
      {required String label,
      required String val,
      required IconData icon,
      required VoidCallback onTap}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(val, style: const TextStyle(fontSize: 12)),
            Icon(icon, size: 16),
          ]),
        ),
      )
    ]);
  }

  Widget _buildSlotItem(int index, AvailabilitySlot slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        const Icon(Icons.event_note, color: Colors.blue, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child: Text('${slot.date} at ${slot.time}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600))),
        IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
            onPressed: () {
              setState(() => _slots.removeAt(index));
              widget.onSlotsUpdated(_slots);
            }),
      ]),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked; //update history
      });
    }
  }

  //select time

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
}
