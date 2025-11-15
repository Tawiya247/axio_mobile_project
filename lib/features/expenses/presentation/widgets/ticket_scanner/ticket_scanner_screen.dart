import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:axio_mobile_project/features/expenses/domain/entities/scanned_ticket.dart';

class TicketScannerScreen extends StatefulWidget {
  final void Function(ScannedTicket) onTicketScanned;

  const TicketScannerScreen({super.key, required this.onTicketScanned});

  @override
  TicketScannerScreenState createState() => TicketScannerScreenState();
}

class TicketScannerScreenState extends State<TicketScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String _status = 'Appuyez sur le bouton pour scanner un ticket';

  Future<void> _scanTicket() async {
    setState(() {
      _isProcessing = true;
      _status = 'Traitement en cours...';
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );

      if (image == null) {
        setState(() => _status = 'Aucune image sélectionnée');
        return;
      }

      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      final scannedTicket = _parseText(recognizedText.text, image.path);

      if (mounted) {
        widget.onTicketScanned(scannedTicket);
        Navigator.of(context).pop(scannedTicket);
      }
    } catch (e) {
      setState(() => _status = 'Erreur lors du scan: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  ScannedTicket _parseText(String text, String imagePath) {
    // Logique de base pour extraire les informations du ticket
    // Cette partie peut être améliorée avec des expressions régulières plus précises
    final lines = text.split('\n');
    String? merchantName;
    double? totalAmount;
    DateTime? date;
    final items = <String>[];

    // Exemple simple d'extraction (à adapter selon le format des tickets)
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Détection du montant total (recherche d'un nombre avec décimales)
      final amountMatch = RegExp(r'\d+[\.,]\d{2}').firstMatch(line);
      if (amountMatch != null) {
        final amountStr = amountMatch.group(0)!.replaceAll(',', '.');
        totalAmount = double.tryParse(amountStr);
      }

      // Détection de la date (format simple)
      final dateMatch = RegExp(r'\d{2}[/-]\d{2}[/-]\d{2,4}').firstMatch(line);
      if (dateMatch != null) {
        date = DateTime.tryParse(dateMatch.group(0)!.replaceAll('/', '-'));
      }

      // Détection du nom du commerçant (première ligne non vide)
      if (merchantName == null && line.length > 3) {
        merchantName = line;
      } else if (line.length > 3) {
        items.add(line);
      }
    }

    return ScannedTicket(
      merchantName: merchantName,
      totalAmount: totalAmount,
      date: date ?? DateTime.now(),
      items: items,
      rawText: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner un ticket'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            if (!_isProcessing)
              FilledButton.icon(
                onPressed: _scanTicket,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scanner un ticket'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              )
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
