import 'package:chat_me/view/pdf.dart';
import 'package:flutter/material.dart';

class DocumentWidget extends StatelessWidget {
  final String fileName;
  final String fileUrl;
  final String fileExtension;

  DocumentWidget({
    required this.fileName,
    required this.fileUrl,
    required this.fileExtension,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _getDocumentIcon(fileExtension), // Icon based on document type
      title: Text(fileName),
      onTap: () {
        // Automatically open the document based on file type
        if (fileExtension == 'pdf') {
          // For PDFs, open in a PDF viewer
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyPdfViewer(
                        url: fileUrl,
                      )));
        } else if (fileExtension == 'doc' ||
            fileExtension == 'docx' ||
            fileExtension == 'ppt') {
          // For doc, docx, ppt, open in a web viewer
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyPdfViewer(
                        url: fileUrl,
                      )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unsupported file type')),
          );
        }
      },
    );
  }

  // Helper function to return the appropriate icon based on the file type
  Widget _getDocumentIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'doc':
      case 'docx':
        return Icon(Icons.description, color: Colors.blue);
      case 'ppt':
        return Icon(Icons.slideshow, color: Colors.orange);
      default:
        return Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }
}
