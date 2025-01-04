import '../../app/generalImports.dart';

class CommonWidgets {
  // Custom Text Field
  static Widget customTextField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      ),
      style: const TextStyle(fontSize: 16.0),
    );
  }

  // Custom Elevated Button
  static Widget customElevatedButton({
    required String text,
    required VoidCallback onPressed,
    Color color = Colors.blue,
    Color textColor = Colors.white,
    double padding = 16.0,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: padding, horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: textColor, fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Custom Radio Button Group for Gender Selection
  static Widget genderRadioButton({
    required int selectedValue,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        ListTile(
          title: const Text('Male'),
          leading: Radio<int>(
            value: 1,
            groupValue: selectedValue,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: const Text('Female'),
          leading: Radio<int>(
            value: 2,
            groupValue: selectedValue,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: const Text('Other'),
          leading: Radio<int>(
            value: 3,
            groupValue: selectedValue,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
