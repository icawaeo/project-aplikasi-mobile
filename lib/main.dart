import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const CurrencyConverterPage(),
    const LatestRatesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Convert',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Historical Rates',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Welcome to Currency Converter App',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  CurrencyConverterPageState createState() => CurrencyConverterPageState();
}

class CurrencyConverterPageState extends State<CurrencyConverterPage> {
  String _fromCurrency = "USD";
  String _toCurrency = "IDR";
  double _amount = 0.0;
  double _result = 0.0;

  // Simbol mata uang
  final Map<String, String> _currencySymbols = {
    "USD": "\$",
    "IDR": "Rp",
    "EUR": "€",
    "JPY": "¥",
    "AUD": "A\$",
  };

  Future<void> _convertCurrency() async {
    final url = Uri.parse(
        "https://api.currencyfreaks.com/latest?apikey=e4133672ad34470dbce972116594876b");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['rates'];
      if (rates.containsKey(_fromCurrency) && rates.containsKey(_toCurrency)) {
        setState(() {
          _result = _amount *
              (double.parse(rates[_toCurrency]) /
                  double.parse(rates[_fromCurrency]));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Currency not found')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch conversion rate')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount'),
            onChanged: (value) {
              _amount = double.tryParse(value) ?? 0.0;
            },
          ),
          DropdownButton<String>(
            value: _fromCurrency,
            items: ['USD', 'IDR', 'EUR', 'JPY', 'AUD']
                .map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _fromCurrency = value!;
              });
            },
          ),
          DropdownButton<String>(
            value: _toCurrency,
            items: ['USD', 'IDR', 'EUR', 'JPY', 'AUD']
                .map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _toCurrency = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _convertCurrency,
            child: const Text('Convert'),
          ),
          const SizedBox(height: 20),
          Text(
            'Result: ${_currencySymbols[_toCurrency] ?? ""} $_result',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class LatestRatesPage extends StatelessWidget {
  final String _apiKey = "e4133672ad34470dbce972116594876b";

  const LatestRatesPage({super.key});

  Future<Map<String, dynamic>> fetchLatestRates() async {
    final url = Uri.parse(
        "https://api.currencyfreaks.com/v2.0/rates/latest?apikey=$_apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch latest rates');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Latest Rates')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchLatestRates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data;
            final rates = data?['rates'] as Map<String, dynamic>;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: rates.entries.map((entry) {
                return ListTile(
                  title: Text('${entry.key}'),
                  subtitle: Text('${entry.value}'),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
