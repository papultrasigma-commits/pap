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
  final _code = TextEditingController(); // Controlador para o código
  
  bool _isRegister = false;
  bool _isVerifying = false; // Variável para saber se estamos a pedir o código
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;
  String? _successMsg; 

  // Função para Login / Pedir Registo
  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
      _successMsg = null;
    });

    String? err;
    if (_isRegister) {
      err = await _auth.register(email: _email.text, password: _pass.text);
      if (err == null) {
        // Se o registo correu bem, mudamos para o ecrã do código!
        if (mounted) {
          setState(() {
            _loading = false;
            _isVerifying = true; // Ativa a interface do código
            _successMsg = "E-mail enviado! Verifica a tua caixa de entrada (ou spam).";
          });
        }
        return;
      }
    } else {
      err = await _auth.login(email: _email.text, password: _pass.text);
      
      // NOVA MAGIA: Se o erro for de falta de verificação, abre o ecrã do código!
      if (err == "Por favor, verifica o teu e-mail primeiro.") {
        if (mounted) {
          setState(() {
            _loading = false;
            _isVerifying = true; // Ativa a interface do código automaticamente
            _successMsg = "A tua conta precisa de ser ativada. Insere o código que recebeste no e-mail.";
            _error = null;
          });
        }
        return;
      }
    }

    if (mounted) setState(() => _loading = false);

    if (err != null) {
      setState(() => _error = err);
      return;
    }
    
    // Se for login e correu bem, avança
    if (!_isRegister) await widget.onDone();
  }

  // Função para Verificar o Código
  Future<void> _verifyCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final err = await _auth.verifyCode(email: _email.text, code: _code.text);

    if (mounted) setState(() => _loading = false);

    if (err != null) {
      setState(() => _error = err);
      return;
    }

    // Se o código estiver certo, avança para a app!
    await widget.onDone();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0505), Color(0xFF0B0B0D), Color(0xFF0B0B0D), Color(0xFF1A0505)],
            stops: [0.0, 0.2, 0.8, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: _isVerifying ? _buildVerificationForm() : _buildLoginForm(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Interface para inserir o Código
  Widget _buildVerificationForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Color(0xFF4A0000), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_outlined, color: Color(0xFFFF8888), size: 28),
        ),
        const SizedBox(height: 24),
        const Text("Verifica o teu E-mail", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_successMsg != null)
          Text(_successMsg!, style: const TextStyle(color: Colors.greenAccent, fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        
        _buildInputLabel("Código de 6 dígitos"),
        const SizedBox(height: 8),
        TextField(
          controller: _code,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8),
          textAlign: TextAlign.center,
          decoration: _buildInputDecoration(hintText: "000000", icon: Icons.password),
        ),
        const SizedBox(height: 20),

        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(_error!, style: const TextStyle(color: Color(0xFFE02424), fontSize: 13), textAlign: TextAlign.center),
          ),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _verifyCode,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE02424), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _loading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text("Confirmar Código →", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() { _isVerifying = false; _error = null; }),
          child: const Text("Voltar atrás", style: TextStyle(color: Colors.grey)),
        )
      ],
    );
  }

  // Interface de Login Original
  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Color(0xFF4A0000), shape: BoxShape.circle),
          child: const Icon(Icons.lock_outline, color: Color(0xFFFF8888), size: 28),
        ),
        const SizedBox(height: 24),
        Text(_isRegister ? "Criar Nova Conta" : "Iniciar Sessão", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(_isRegister ? "Registe-se para aceder à plataforma." : "Bem-vindo de volta!", style: const TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isRegister = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: !_isRegister ? const Color(0xFF333333) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text("Login", style: TextStyle(color: !_isRegister ? Colors.white : Colors.grey, fontWeight: !_isRegister ? FontWeight.bold : FontWeight.normal))),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isRegister = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: _isRegister ? const Color(0xFF333333) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text("Registo", style: TextStyle(color: _isRegister ? Colors.white : Colors.grey, fontWeight: _isRegister ? FontWeight.bold : FontWeight.normal))),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _buildInputLabel("E-mail"),
        const SizedBox(height: 8),
        TextField(controller: _email, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: Colors.white), decoration: _buildInputDecoration(hintText: "exemplo@dominio.pt", icon: Icons.mail_outline)),
        const SizedBox(height: 20),
        _buildInputLabel("Palavra-passe"),
        const SizedBox(height: 8),
        TextField(
          controller: _pass, obscureText: _obscurePassword, style: const TextStyle(color: Colors.white),
          decoration: _buildInputDecoration(hintText: "••••••••", icon: Icons.lock_outline).copyWith(
            suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
          ),
        ),
        const SizedBox(height: 20),
        if (_error != null)
          Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(_error!, style: const TextStyle(color: Color(0xFFE02424), fontSize: 13), textAlign: TextAlign.center)),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE02424), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _loading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_isRegister ? "Criar Conta →" : "Entrar Agora →", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String text) {
    return Align(alignment: Alignment.centerLeft, child: Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500)));
  }

  InputDecoration _buildInputDecoration({required String hintText, required IconData icon}) {
    return InputDecoration(
      hintText: hintText, hintStyle: TextStyle(color: Colors.grey[600]), filled: true, fillColor: const Color(0xFF222222),
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 20), contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE02424), width: 1.5)),
    );
  }
}