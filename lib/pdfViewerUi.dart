// import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
// import 'package:flutter/material.dart';

// class PdfViewerUi extends StatefulWidget {
//   final pdfUrl;
//   PdfViewerUi({this.pdfUrl});

//   @override
//   _PdfViewerUiState createState() => _PdfViewerUiState();
// }

// class _PdfViewerUiState extends State<PdfViewerUi> {
//   bool _isLoading = true;
//   PDFDocument? document;
//   @override
//   void initState() {
//     super.initState();
//     loadDocument();
//   }

//   loadDocument() async {
//     document = await PDFDocument.fromURL(
//         'https://firebasestorage.googleapis.com/v0/b/socialmediaapp-20625.appspot.com/o/posts%2FoEqTW6EF6iQcPA4BPie7r4uAwdJ2%2F2022-02-28%2019%3A39%3A17.738933?alt=media&token=fa576006-9caf-4b4c-918a-7d68e6d31fda');

//     setState(() => _isLoading = false);
//   }

//   // changePDF(value) async {
//   //   setState(() => _isLoading = true);
//   //   if (value == 1) {
//   //     document = await PDFDocument.fromAsset('assets/sample2.pdf');
//   //   } else if (value == 2) {
//   //     document = await PDFDocument.fromURL(
//   //       "https://unec.edu.az/application/uploads/2014/12/pdf-sample.pdf",
//   //       /* cacheManager: CacheManager(
//   //         Config(
//   //           "customCacheKey",
//   //           stalePeriod: const Duration(days: 2),
//   //           maxNrOfCacheObjects: 10,
//   //         ),
//   //       ), */
//   //     );
//   //   } else {
//   //     document = await PDFDocument.fromAsset('assets/sample.pdf');
//   //   }
//   //   setState(() => _isLoading = false);
//   //   Navigator.pop(context);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: _isLoading
//             ? Center(child: CircularProgressIndicator())
//             : PDFViewer(
//                 document: document!,
//                 zoomSteps: 1,
//                 //uncomment below line to preload all pages
//                 lazyLoad: false,
//                 // uncomment below line to scroll vertically
//                 scrollDirection: Axis.vertical,

//                 //uncomment below code to replace bottom navigation with your own
//                 navigationBuilder:
//                     (context, page, totalPages, jumpToPage, animateToPage) {
//                   return ButtonBar(
//                     alignment: MainAxisAlignment.spaceEvenly,
//                     children: <Widget>[
//                       IconButton(
//                         icon: Icon(Icons.first_page),
//                         onPressed: () {
//                           jumpToPage(page: 0);
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.arrow_back),
//                         onPressed: () {
//                           animateToPage(page: page! - 2);
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.arrow_forward),
//                         onPressed: () {
//                           animateToPage(page: page);
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.last_page),
//                         onPressed: () {
//                           jumpToPage(page: totalPages! - 1);
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }
