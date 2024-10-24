// lib/main.dart
import 'package:flutter/material.dart';
import 'package:alimento/models/alimento.dart';
import 'package:alimento/helpers/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Mercado',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();

  List<Alimento> _alimentos = [];
  bool _isLoading = false;
  Future<void> _loadAlimentos() async {
    setState(() => _isLoading = true);
    final alimentos = await SqlHelper().getAllAlimentos();
    setState(() {
      _alimentos = alimentos;
      _isLoading = false;
    });
  }

  Future<void> _showAddAlimentoDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Alimento'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor insira um nome';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _precoController,
                  decoration: const InputDecoration(labelText: 'Preço'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Por favor insira um preço válido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 148, 85, 61)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color.fromARGB(255, 105, 64, 49)),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 148, 85, 61)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addAlimento();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar',
                  style: TextStyle(color: Color.fromARGB(255, 105, 64, 49))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addAlimento() async {
    if (_nomeController.text.isNotEmpty && _precoController.text.isNotEmpty) {
      try {
        final double preco = double.parse(_precoController.text);

        setState(() => _isLoading = true);
        await SqlHelper().insertAlimento(Alimento(
          nome: _nomeController.text,
          preco: preco,
        ));
        _nomeController.clear();
        _precoController.clear();
        await _loadAlimentos();
      } catch (e) {
        // Mostre uma mensagem de erro se a conversão falhar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Preço inválido. Insira um número válido.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
    }
  }

  Future<void> _showUpdateAlimentoDialog(Alimento alimento) async {
    _nomeController.text = alimento.nome;
    _precoController.text = alimento.preco.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Alimento'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor insira um nome';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _precoController,
                  decoration: const InputDecoration(labelText: 'Preço'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Por favor insira um preço válido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 148, 85, 61)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar',
                  style: TextStyle(color: Color.fromARGB(255, 105, 64, 49))),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 148, 85, 61)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updateAlimento(alimento);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Atualizar',
                  style: TextStyle(color: Color.fromARGB(255, 105, 64, 49))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAlimento(Alimento alimento) async {
    if (_nomeController.text.isNotEmpty && _precoController.text.isNotEmpty) {
      try {
        final double preco = double.parse(_precoController.text);

        setState(() => _isLoading = true);
        // Atualize o objeto `Alimento` com os novos valores
        alimento.nome = _nomeController.text;
        alimento.preco = preco;

        // Envie os dados atualizados ao banco de dados
        await SqlHelper().updateAlimento(alimento);
        _nomeController.clear();
        _precoController.clear();
        await _loadAlimentos();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Preço inválido. Insira um número válido.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
    }
  }

  Future<void> _deleteAlimento(int id) async {
    setState(() => _isLoading = true);
    await SqlHelper().deleteAlimento(id);
    await _loadAlimentos();
  }

  @override
  void initState() {
    super.initState();
    _loadAlimentos();
  }

  @override
  Widget build(BuildContext context) {
    final seedColor = Colors.orange;

    final themeData = Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
    );

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Minhas Compras',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          backgroundColor: themeData.colorScheme.primary),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _alimentos.length,
              itemBuilder: (context, index) {
                final alimento = _alimentos[index];
                return Card(
                  child: ListTile(
                    title: Text(alimento.nome,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    subtitle: Text(
                      'Preço: R\$${alimento.preco.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () => _showUpdateAlimentoDialog(alimento),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          onPressed: () => _deleteAlimento(alimento.id!),
                        ),
                      ],
                    ),
                  ),
                  color: themeData.colorScheme.inversePrimary,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeData.colorScheme.primaryContainer,
        onPressed: _showAddAlimentoDialog,
        tooltip: 'Adicionar Alimento',
        child: const Icon(Icons.add),
      ),
    );
  }
}
