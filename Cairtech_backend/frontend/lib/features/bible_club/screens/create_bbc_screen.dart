import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';

class CreateBbcScreen extends ConsumerStatefulWidget {
  const CreateBbcScreen({super.key});

  @override
  ConsumerState<CreateBbcScreen> createState() => _CreateBbcScreenState();
}

class _CreateBbcScreenState extends ConsumerState<CreateBbcScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _localisationController = TextEditingController();
  final _villeController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _schoolLevelController = TextEditingController();
  final _capacityController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _localisationController.dispose();
    _villeController.dispose();
    _schoolNameController.dispose();
    _schoolLevelController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(bibleClubRepositoryProvider);
      await repo.createBibleClub(
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        localisation: _localisationController.text.trim(),
        ville: _villeController.text.trim(),
        schoolName: _schoolNameController.text.trim(),
        schoolLevel: _schoolLevelController.text.trim(),
        capacityMax: int.tryParse(_capacityController.text.trim()),
        dateCreation: DateTime.now().toString().split(' ').first,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bible Club créé avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Créer un Bible Club'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField('Nom du Club *', _nameController, 'Ex: Heritage High School BBC'),
              _buildField('Code *', _codeController, 'Ex: HHS-BBC'),
              _buildField('Localisation', _localisationController, 'Ex: Quartier Nord'),
              _buildField('Ville', _villeController, 'Ex: Douala'),
              _buildField('Nom de l\'école', _schoolNameController, 'Ex: Heritage High School'),
              _buildField('Niveau scolaire', _schoolLevelController, 'Ex: Secondaire'),
              _buildField('Capacité max', _capacityController, 'Ex: 120',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Créer le Bible Club'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isRequired = label.contains('*');
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: hint),
            validator: isRequired
                ? (v) => (v == null || v.isEmpty) ? 'Ce champ est requis' : null
                : null,
          ),
        ],
      ),
    );
  }
}
