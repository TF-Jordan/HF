import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';

class CreateMemberScreen extends ConsumerStatefulWidget {
  const CreateMemberScreen({super.key});

  @override
  ConsumerState<CreateMemberScreen> createState() => _CreateMemberScreenState();
}

class _CreateMemberScreenState extends ConsumerState<CreateMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _quarterController = TextEditingController();
  final _levelController = TextEditingController();
  final _sectorController = TextEditingController();
  final _bbcIdController = TextEditingController();
  String _gender = 'M';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _quarterController.dispose();
    _levelController.dispose();
    _sectorController.dispose();
    _bbcIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).user;
      // Use admin endpoint if admin, otherwise use member endpoint
      if (user != null && user.isAdmin) {
        final repo = ref.read(adminRepositoryProvider);
        await repo.createMember(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phoneNumber: _phoneController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
          gender: _gender,
          address: _addressController.text.trim(),
          quarter: _quarterController.text.trim(),
          level: _levelController.text.trim(),
          sector: _sectorController.text.trim(),
          idBbc: _bbcIdController.text.trim(),
          inscriptionDate: DateTime.now().toString().split(' ').first,
        );
      } else {
        final repo = ref.read(memberRepositoryProvider);
        await repo.createMember(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phoneNumber: _phoneController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
          gender: _gender,
          address: _addressController.text.trim(),
          quarter: _quarterController.text.trim(),
          level: _levelController.text.trim(),
          sector: _sectorController.text.trim(),
          idBbc: _bbcIdController.text.trim(),
          inscriptionDate: DateTime.now().toString().split(' ').first,
        );
      }

      ref.refresh(allMembersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membre créé avec succès !'),
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
        title: const Text('Nouveau Membre'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Account section
              _buildSectionTitle('Compte'),
              _buildField('Email *', _emailController, 'email@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                if (v == null || v.isEmpty) return 'Email requis';
                if (!v.contains('@')) return 'Email invalide';
                return null;
              }),
              _buildField('Mot de passe *', _passwordController, '••••••••',
                  obscure: true, validator: (v) {
                if (v == null || v.isEmpty) return 'Mot de passe requis';
                if (v.length < 6) return '6 caractères minimum';
                return null;
              }),
              _buildField('Téléphone *', _phoneController, '+237 6XX XXX XXX',
                  keyboardType: TextInputType.phone),

              const SizedBox(height: 8),
              _buildSectionTitle('Informations personnelles'),
              _buildField('Prénom *', _firstNameController, 'John'),
              _buildField('Nom *', _lastNameController, 'Doe'),
              _buildField('Date de naissance', _dobController, 'YYYY-MM-DD'),

              // Gender selector
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Genre',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildGenderChip('M', 'Masculin'),
                        const SizedBox(width: 12),
                        _buildGenderChip('F', 'Féminin'),
                      ],
                    ),
                  ],
                ),
              ),

              _buildField('Adresse', _addressController, 'Adresse complète'),
              _buildField('Quartier', _quarterController, 'Ex: Bonamoussadi'),

              const SizedBox(height: 8),
              _buildSectionTitle('Affectation'),
              _buildField('Niveau', _levelController, 'Ex: Grade 10'),
              _buildField('Secteur', _sectorController, 'Ex: Secteur A'),
              _buildField('ID du Bible Club *', _bbcIdController, 'UUID du BBC',
                  validator: (v) {
                if (v == null || v.isEmpty) return 'BBC requis';
                return null;
              }),

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
                      : const Text('Créer le membre'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildGenderChip(String value, String label) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
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
    bool obscure = false,
    String? Function(String?)? validator,
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
            obscureText: obscure,
            decoration: InputDecoration(hintText: hint),
            validator: validator ??
                (isRequired
                    ? (v) => (v == null || v.isEmpty) ? 'Ce champ est requis' : null
                    : null),
          ),
        ],
      ),
    );
  }
}
