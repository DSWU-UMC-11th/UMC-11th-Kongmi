import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common_app_bar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
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

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('이용약관에 동의해주세요.')));
        return;
      }
      // 회원가입 성공 처리 로직
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

              // 이메일 입력
              const Text('이메일', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'example@movielog.com',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요.';
                  }
                  if (!value.contains('@')) {
                    return '올바른 이메일 형식이 아닙니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 비밀번호 입력
              const Text('비밀번호', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '영문, 숫자 포함 8자리 이상',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  if (value.length < 8) {
                    return '비밀번호는 8자리 이상이어야 합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text('닉네임', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(hintText: '사용하실 닉네임을 입력해주세요'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
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

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '가입하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
