import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/password_strength_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/social_button.dart';
import '../../widgets/trust_badge.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _agreeToTerms = true;
  PasswordStrength _passwordStrength = const PasswordStrength(
    score: 1,
    label: 'Lemah',
  );

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    final text = _passwordController.text;
    setState(() {
      if (text.isEmpty) {
        _passwordStrength = const PasswordStrength(score: 1, label: 'Lemah');
      } else {
        _passwordStrength = Validators.calculatePasswordStrength(text);
      }
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap setujui Ketentuan Layanan & Kebijakan Privasi terlebih dahulu',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Format nomor telepon dengan prefix +62
      String? formattedPhone;
      final rawPhone = _phoneController.text.trim();
      if (rawPhone.isNotEmpty) {
        if (rawPhone.startsWith('+62')) {
          formattedPhone = rawPhone;
        } else if (rawPhone.startsWith('0')) {
          formattedPhone = '+62${rawPhone.substring(1)}';
        } else if (rawPhone.startsWith('62')) {
          formattedPhone = '+$rawPhone';
        } else {
          formattedPhone = '+62$rawPhone';
        }
      }

      final success = await authProvider.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: formattedPhone,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pendaftaran berhasil! Selamat datang, ${authProvider.currentUser?.fullName ?? ''}',
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Langsung masuk ke HomeScreen sesuai permintaan
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        final errorMsg = authProvider.errorMessage ?? 'Pendaftaran gagal. Silakan coba lagi.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    // App Logo
                    const AppLogo(size: 64),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Buat Akun Baru',
                      style: AppTextStyles.headingLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Mulai titip barang impian atau raih cuan jadi traveler jastiper terpercaya.',
                        style: AppTextStyles.bodySubtitle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Full Name Field
                    CustomTextField(
                      label: 'Nama Lengkap',
                      hintText: 'Masukan Nama Lengkap',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (val) =>
                          Validators.validateRequired(val, 'Nama Lengkap'),
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    CustomTextField(
                      label: 'Alamat Email',
                      hintText: 'Masukan Email',
                      controller: _emailController,
                      prefixIcon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Phone Number Field with +62 badge
                    CustomTextField(
                      label: 'Nomor Telepon',
                      hintText: 'Masukan Nomor Telepon',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: Validators.validatePhone,
                      prefixWidget: Container(
                        margin: const EdgeInsets.only(
                          left: 6,
                          right: 12,
                          top: 6,
                          bottom: 6,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          '+62',
                          style: AppTextStyles.fieldLabel.copyWith(
                            fontSize: 13.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    CustomTextField(
                      label: 'Kata Sandi',
                      hintText: 'Minimal 8 karakter unik',
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 12),

                    // Password Strength Bar
                    PasswordStrengthBar(
                      score: _passwordStrength.score,
                      label: _passwordStrength.label,
                    ),
                    const SizedBox(height: 18),

                    // Terms & Conditions Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreeToTerms,
                            onChanged: (val) {
                              setState(() {
                                _agreeToTerms = val ?? false;
                              });
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            activeColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Saya menyetujui ',
                              style: AppTextStyles.termsText,
                              children: [
                                TextSpan(
                                  text: 'Ketentuan Layanan',
                                  style: AppTextStyles.termsTextBold.copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Buka Ketentuan Layanan'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                ),
                                const TextSpan(text: ' & '),
                                TextSpan(
                                  text: 'Kebijakan Privasi Jastipgo.',
                                  style: AppTextStyles.termsTextBold.copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Buka Kebijakan Privasi'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Primary Button (Daftar Sekarang)
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => PrimaryButton(
                        text: 'Daftar Sekarang',
                        isLoading: auth.isLoading,
                        onPressed: auth.isLoading ? null : _handleRegister,
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Divider "ATAU"
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: AppColors.border,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Text(
                            'ATAU',
                            style: AppTextStyles.dividerText,
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: AppColors.border,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Social Login Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SocialButton.google(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Daftar dengan Google'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SocialButton.apple(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Daftar dengan Apple'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Login Footer Link
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: AppTextStyles.bodySmall,
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Masuk di sini',
                              style: AppTextStyles.linkText.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Trust Badge
                    const TrustBadge(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
