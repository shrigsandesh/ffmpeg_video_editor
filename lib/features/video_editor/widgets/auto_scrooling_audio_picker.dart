  //  Stack(
  //           children: [
  //             AutoScroller(
  //               lengthIdentifier: videoDuration,
  //               builder: (context, scrollController) {
  //                 return SingleChildScrollView(
  //                   controller: _scrollController,
  //                   scrollDirection: Axis.horizontal,
  //                   reverse: true,
  //                   child: SizedBox(
  //                     height: 200,
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: generateTimeWidgets(videoDuration,
  //                               MediaQuery.of(context).size.width - 1),
  //                         ),
  //                         Flexible(
  //                           child: FutureBuilder<List<File>>(
  //                             future: generateThumbnails(
  //                                 videoDuration, _videoFile.path),
  //                             builder: (context, snapshot) {
  //                               if (snapshot.connectionState ==
  //                                   ConnectionState.done) {
  //                                 return SizedBox(
  //                                   height: 300,
  //                                   child: ListView.builder(
  //                                     shrinkWrap: true,
  //                                     controller: _scrollController,
  //                                     scrollDirection: Axis.horizontal,
  //                                     itemCount: videoDuration +
  //                                         1, // Add 1 for the initial space
  //                                     itemBuilder: (context, index) {
  //                                       if (index == 0) {
  //                                         // First item is blank space equal to half screen width
  //                                         return SizedBox(
  //                                             width: screenWidth / 2);
  //                                       }
  //                                       return Padding(
  //                                         padding: const EdgeInsets.symmetric(
  //                                             horizontal: 8.0),
  //                                         child: Image.file(
  //                                           snapshot.data![index],
  //                                           fit: BoxFit.cover,
  //                                           height: 10,
  //                                         ),
  //                                       );
  //                                     },
  //                                   ),
  //                                 );

  //                               } else {
  //                                 return const Center(
  //                                     child: CircularProgressIndicator());
  //                               }
  //                             },
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //             // SingleChildScrollView(
  //             //   controller: _scrollController,
  //             //   reverse: true,
  //             //   scrollDirection: Axis.horizontal,
  //             //   child: SizedBox(
  //             //     height: 200,
  //             //     child: Column(
  //             //       crossAxisAlignment: CrossAxisAlignment.start,
  //             //       mainAxisSize: MainAxisSize.min,
  //             //       children: [
  //             //         Row(
  //             //           mainAxisSize: MainAxisSize.min,
  //             //           children: generateTimeWidgets(videoDuration,
  //             //               MediaQuery.of(context).size.width - 1),
  //             //         ),
  //             //         Flexible(
  //             //           child: FutureBuilder<List<File>>(
  //             //             future: generateThumbnails(
  //             //                 videoDuration, _videoFile.path),
  //             //             builder: (context, snapshot) {
  //             //               if (snapshot.connectionState ==
  //             //                   ConnectionState.done) {
  //             //                 return ListView.builder(
  //             //                   shrinkWrap: true,
  //             //                   scrollDirection: Axis.horizontal,
  //             //                   itemCount: videoDuration + 1,
  //             //                   reverse: true,
  //             //                   itemBuilder: (context, index) {
  //             //                     if (index == videoDuration) {
  //             //                       return SizedBox(
  //             //                         width:
  //             //                             (MediaQuery.of(context).size.width -
  //             //                                     1) /
  //             //                                 2,
  //             //                       );
  //             //                     }
  //             //                     return Image.file(
  //             //                       snapshot.data![index],
  //             //                       fit: BoxFit.cover,
  //             //                       height: 10,
  //             //                     );
  //             //                   },
  //             //                 );
  //             //               } else {
  //             //                 return const Center(
  //             //                     child: CircularProgressIndicator());
  //             //               }
  //             //             },
  //             //           ),
  //             //         ),
  //             //       ],
  //             //     ),
  //             //   ),
  //             // ),

  //             Center(
  //               child: Container(
  //                 height: 320,
  //                 width: 2,
  //                 color: Colors.white,
  //               ),
  //             )
  //           ],
  //         ),
        