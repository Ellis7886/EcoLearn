import 'package:flutter/material.dart';

class SettingSwitch extends StatefulWidget {

  final String title;
  final String description;
  final IconData icon;
  final bool initialValue;
  final Function(bool)? onChanged;

  const SettingSwitch({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.initialValue = true,
    this.onChanged,
  });

  @override
  State<SettingSwitch> createState() =>
      _SettingSwitchState();
}

class _SettingSwitchState
    extends State<SettingSwitch> {

  late bool switchValue;

  @override
  void initState() {
    super.initState();

    switchValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),

      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,

        children: [

          Icon(
            widget.icon,
            color: const Color(0xFF9BD028),
            size: 40,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          Transform.scale(
            scale: 0.6,

            child: Switch(
              value: switchValue,

              onChanged: (value) {

                setState(() {
                  switchValue = value;
                });

                if(widget.onChanged != null){
                  widget.onChanged!(value);
                }
              },

              activeThumbColor: Colors.white,

              activeTrackColor:
              const Color(0xFF9BD028),

              inactiveThumbColor:
              Colors.white,

              inactiveTrackColor:
              Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}