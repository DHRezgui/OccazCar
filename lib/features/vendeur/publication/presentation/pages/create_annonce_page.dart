import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/di/injection.dart';

class CreateAnnoncePage extends ConsumerStatefulWidget {
  const CreateAnnoncePage({super.key});

  @override
  ConsumerState<CreateAnnoncePage> createState() => _CreateAnnoncePageState();
}

class _CreateAnnoncePageState extends ConsumerState<CreateAnnoncePage> {
  final _formKey = GlobalKey<FormState>();
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'make': _makeCtrl.text.trim(),
      'model': _modelCtrl.text.trim(),
      'year': int.tryParse(_yearCtrl.text) ?? 0,
      'price': double.tryParse(_priceCtrl.text) ?? 0.0,
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      await ref.read(firebaseServiceProvider).createAnnonce(data);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Annonce créée (test)')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer annonce (test)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _makeCtrl,
                decoration: const InputDecoration(labelText: 'Marque'),
                validator: (v) => v == null || v.isEmpty ? 'Obligatoire' : null,
              ),
              TextFormField(
                controller: _modelCtrl,
                decoration: const InputDecoration(labelText: 'Modèle'),
                validator: (v) => v == null || v.isEmpty ? 'Obligatoire' : null,
              ),
              TextFormField(
                controller: _yearCtrl,
                decoration: const InputDecoration(labelText: 'Année'),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null || int.tryParse(v) == null)
                            ? 'Année valide requise'
                            : null,
              ),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null || double.tryParse(v) == null)
                            ? 'Prix valide requis'
                            : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Créer (test)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
