import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  final Future<void> Function() onDone;
  const LoginPage({super.key, required this.onDone});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  
  bool _isRegister = false;
  bool _loading = false;
  bool _obscurePassword = true; // Para mostrar/esconder a password
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    String? err;
    if (_isRegister) {
      err = await _auth.register(email: _email.text, password: _pass.text);
    } else {
      err = await _auth.login(email: _email.text, password: _pass.text);
    }

    if (mounted) {
      setState(() => _loading = false);
    }

    if (err != null) {
      setState(() => _error = err);
      return;
    }

    await widget.onDone();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo ocupa 100% da viewport (full screen) sem appBar
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradiente muito suave nas laterais com tons de vermelho escuro/bordô
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A0505), // Bordô escuro na esquerda
              Color(0xFF0B0B0D), // Quase preto ao centro
              Color(0xFF0B0B0D),
              Color(0xFF1A0505), // Bordô escuro na direita
            ],
            stops: [0.0, 0.2, 0.8, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Botão de Voltar (Canto Superior Esquerdo)
              Positioned(
                top: 16,
                left: 16,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    // Lógica para voltar, se aplicável
                    Navigator.maybePop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1A1A), // Cinza muito escuro
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Conteúdo Central
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111), // Card cinza muito escuro/preto
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ícone Superior
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4A0000), // Fundo vermelho escuro
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFFFF8888), // Vermelho claro
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Títulos
                          Text(
                            _isRegister ? "Criar Nova Conta" : "Iniciar Sessão",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter', // Se tiveres a fonte configurada
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isRegister 
                                ? "Registe-se para aceder à plataforma." 
                                : "Bem-vindo de volta! Introduza os seus dados.",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Tabs (Login / Registo)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isRegister = false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: !_isRegister ? const Color(0xFF333333) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Login",
                                          style: TextStyle(
                                            color: !_isRegister ? Colors.white : Colors.grey,
                                            fontWeight: !_isRegister ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isRegister = true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _isRegister ? const Color(0xFF333333) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Registo",
                                          style: TextStyle(
                                            color: _isRegister ? Colors.white : Colors.grey,
                                            fontWeight: _isRegister ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Campo E-mail
                          _buildInputLabel("E-mail"),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration(
                              hintText: "exemplo@dominio.pt",
                              icon: Icons.mail_outline,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Campo Palavra-passe
                          _buildInputLabel("Palavra-passe"),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _pass,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: _buildInputDecoration(
                              hintText: "••••••••",
                              icon: Icons.lock_outline,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Mensagem de Erro
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Color(0xFFE02424), fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // Botão Principal (CTA)
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE02424), // Vermelho vivo
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: const Color(0xFFE02424).withOpacity(0.5),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isRegister ? "Criar Conta →" : "Entrar Agora →",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Texto Inferior
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isRegister ? "Já tem conta? " : "Ainda não tem conta? ",
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _isRegister = !_isRegister),
                                child: Text(
                                  _isRegister ? "Inicie sessão aqui" : "Registe-se aqui",
                                  style: const TextStyle(
                                    color: Color(0xFFE02424),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Rodapé Discreto
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shield_outlined, color: Colors.white38, size: 14),
                        SizedBox(width: 6),
                        Text(
                          "Protegido por encriptação AES-256",
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "© 2026 Sistema de Autenticação – Todos os direitos reservados",
                      style: TextStyle(color: Colors.white24, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para criar as Labels dos Inputs
  Widget _buildInputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Helper para criar a decoração dos TextFields
  InputDecoration _buildInputDecoration({required String hintText, required IconData icon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: const Color(0xFF222222), // Fundo cinza escuro do input
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE02424), width: 1.5), // Borda vermelha ao focar
      ),
    );
  }
}