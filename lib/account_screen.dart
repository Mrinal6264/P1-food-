import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class AccountScreen extends StatefulWidget {
  final bool embedded;
  const AccountScreen({super.key, this.embedded = false});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _editing = false;
  bool _saving = false;
  late TextEditingController _name;
  late TextEditingController _phone;
  late TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _address = TextEditingController(text: user?.address ?? '');
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().updateProfile(_name.text.trim(), _phone.text.trim(), _address.text.trim());
      if (mounted) {
        setState(() => _editing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log out')),
        ],
      ),
    );
    if (confirmed != true) return;
    await context.read<AuthProvider>().logout();
    if (mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final body = SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(radius: 36, backgroundColor: Colors.deepOrange.shade100, child: Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 28))),
          const SizedBox(height: 12),
          Center(child: Text(user?.name ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Center(child: Text(user?.email ?? '', style: const TextStyle(color: Colors.grey))),
          const SizedBox(height: 24),
          if (_editing) ...[
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _address, maxLines: 2, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _editing = false), child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save'),
                  ),
                ),
              ],
            ),
          ] else ...[
            _infoTile(Icons.phone_outlined, 'Phone', user?.phone ?? '-'),
            _infoTile(Icons.location_on_outlined, 'Address', (user?.address?.isNotEmpty ?? false) ? user!.address! : 'Not set'),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: () => setState(() => _editing = true), icon: const Icon(Icons.edit_outlined), label: const Text('Edit Profile')),
          ],
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Log out', style: TextStyle(color: Colors.red)), onTap: _logout),
        ],
      ),
    );

    if (widget.embedded) {
      return Scaffold(appBar: AppBar(title: const Text('Account'), automaticallyImplyLeading: false), body: body);
    }
    return Scaffold(appBar: AppBar(title: const Text('Account')), body: body);
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
