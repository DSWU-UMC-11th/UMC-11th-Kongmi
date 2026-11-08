import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/create_member_request.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/movielog_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
final _lowerPattern = RegExp(r'[a-z]');
final _upperPattern = RegExp(r'[A-Z]');
final _digitPattern = RegExp(r'[0-9]');
final _specialPattern = RegExp(r'[!@#$%^&*]');

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameFieldKey = GlobalKey<FormFieldState<String>>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  String? _validateNickname(String? value) {
    final nickname = value?.trim() ?? '';
    if (nickname.isEmpty) return '닉네임을 입력해주세요.';
    if (nickname.length < 2 || nickname.length > 12) {
      return '닉네임은 2~12자로 입력해주세요.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return '이메일을 입력해주세요.';
    if (!_emailPattern.hasMatch(email)) return '올바른 이메일 형식이 아닙니다.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return '비밀번호를 입력해주세요.';
    if (value != value.trim()) return '비밀번호 앞뒤에 공백을 넣을 수 없습니다.';
    if (value.length < 8 ||
        !_lowerPattern.hasMatch(value) ||
        !_upperPattern.hasMatch(value) ||
        !_digitPattern.hasMatch(value) ||
        !_specialPattern.hasMatch(value)) {
      return '대문자·소문자·숫자·특수문자(!@#\$%^&*)를 포함해 8자 이상 입력해주세요.';
    }
    return null;
  }

  void _checkNickname(SignUpViewModel viewModel) {
    if (_nicknameFieldKey.currentState?.validate() ?? false) {
      viewModel.checkNickname(_nicknameController.text);
    }
  }

  void _checkEmail(SignUpViewModel viewModel) {
    if (_emailFieldKey.currentState?.validate() ?? false) {
      viewModel.checkEmail(_emailController.text);
    }
  }

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final viewModel = context.read<SignUpViewModel>();
    final session = context.read<LearningMemberSession>();
    await viewModel.submit(
      CreateMemberRequest(
        email: _emailController.text,
        password: _passwordController.text,
        nickname: _nicknameController.text,
      ),
    );
    if (!mounted) return;

    final memberId = viewModel.createdMemberId;
    if (viewModel.submitStatus == SubmitStatus.success && memberId != null) {
      session.setMemberId(memberId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입이 완료되었습니다. (memberId: $memberId)')),
      );
      context.go('/movies');
      return;
    }

    final message = viewModel.snackbarMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();
    final isSubmitting = viewModel.isSubmitting;
    final canSubmit = _agreeToTerms && viewModel.isBothAvailable && !isSubmitting;

    return PopScope(
      canPop: !isSubmitting,
      child: Scaffold(
      appBar: const CommonAppBar(title: '회원가입'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '무비로그와 함께\n영화 기록을 시작해보세요',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: 32),
              _CheckInputRow(
                label: '닉네임',
                hint: '사용하실 닉네임을 입력해주세요',
                fieldKey: _nicknameFieldKey,
                controller: _nicknameController,
                status: viewModel.nicknameCheckStatus,
                errorText: viewModel.nicknameErrorText,
                canCheck: viewModel.canCheckNickname,
                enabled: !isSubmitting,
                onChanged: viewModel.onNicknameChanged,
                onCheck: () => _checkNickname(viewModel),
                validator: _validateNickname,
                availableText: '사용 가능한 닉네임입니다.',
                checkingText: '닉네임 사용 가능 여부를 확인 중입니다.',
              ),
              const SizedBox(height: 24),
              _CheckInputRow(
                label: '이메일',
                hint: 'example@movielog.com',
                fieldKey: _emailFieldKey,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                status: viewModel.emailCheckStatus,
                errorText: viewModel.emailErrorText,
                canCheck: viewModel.canCheckEmail,
                enabled: !isSubmitting,
                onChanged: viewModel.onEmailChanged,
                onCheck: () => _checkEmail(viewModel),
                validator: _validateEmail,
                availableText: '사용 가능한 이메일입니다.',
                checkingText: '이메일 사용 가능 여부를 확인 중입니다.',
              ),
              const SizedBox(height: 24),
              const Text('비밀번호', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !isSubmitting,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (_) => viewModel.onPasswordChanged(),
                decoration: InputDecoration(
                  hintText: '대·소문자, 숫자, 특수문자 포함 8자 이상',
                  errorText: viewModel.passwordErrorText,
                  errorMaxLines: 2,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                    activeColor: AppColors.violet,
                  ),
                  const Expanded(
                    child: Text(
                      '서비스 이용약관 및 개인정보 처리방침에 동의합니다.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              MovieLogButton(
                label: '가입하기',
                width: double.infinity,
                isLoading: isSubmitting,
                onPressed: canSubmit ? _handleSignUp : null,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _CheckInputRow extends StatelessWidget {
  const _CheckInputRow({
    required this.label,
    required this.hint,
    required this.fieldKey,
    required this.controller,
    required this.status,
    required this.errorText,
    required this.canCheck,
    required this.onChanged,
    required this.onCheck,
    required this.validator,
    required this.availableText,
    required this.checkingText,
    this.keyboardType,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final GlobalKey<FormFieldState<String>> fieldKey;
  final TextEditingController controller;
  final CheckStatus status;
  final String? errorText;
  final bool canCheck;
  final ValueChanged<String> onChanged;
  final VoidCallback onCheck;
  final FormFieldValidator<String> validator;
  final String availableText;
  final String checkingText;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                key: fieldKey,
                controller: controller,
                keyboardType: keyboardType,
                enabled: enabled,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: hint,
                  errorText: errorText,
                  suffixIcon: status == CheckStatus.available
                      ? const Icon(Icons.check_circle, color: AppColors.violet)
                      : null,
                ),
                validator: validator,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            MovieLogButton(
              label: '중복 확인',
              isLoading: status == CheckStatus.checking,
              onPressed: canCheck ? onCheck : null,
            ),
          ],
        ),
        if (status == CheckStatus.available)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              availableText,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.green.shade700),
            ),
          ),
        if (status == CheckStatus.checking)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              checkingText,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.blue.shade700),
            ),
          ),
      ],
    );
  }
}