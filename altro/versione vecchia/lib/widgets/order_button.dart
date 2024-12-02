class OrderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const OrderButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
      icon: Icon(icon, color: Colors.white),
      backgroundColor: color,
    );
  }
}