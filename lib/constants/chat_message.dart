import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:flutter/material.dart';

import 'formate_date.dart';

class ChatMessage extends StatefulWidget {
  final MessageModel msg;
  final String currentUser;
  final bool isImage;
  
  const ChatMessage({super.key, 
  required this.msg, 
  required this.currentUser, 
  required this.isImage
  });

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return widget.isImage
       // ignore: avoid_unnecessary_containers
       ? Container(
         child: Row(
         mainAxisAlignment:  widget.msg.sender==widget.currentUser
       ? MainAxisAlignment.end
       : MainAxisAlignment.start,
    children: [
     Column(
       crossAxisAlignment:  widget.msg.sender==widget.currentUser
           ? CrossAxisAlignment.end
           : CrossAxisAlignment.start,
       children: [
         Container(
           margin: const EdgeInsets.all(4),
           child: ClipRRect(
             borderRadius: BorderRadius.circular(10),
             child: CachedNetworkImage(
               imageUrl: "https://cloud.appwrite.io/v1/storage/buckets/662faabe001a20bb87c6/files/${widget.msg.message}/view?project=662e8e5c002f2d77a17c&mode=admin",
               height: 200,
               width: 200,
               fit: BoxFit.cover,
             ),
           ),
         ),
            Row(
              mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(formatDate(widget.msg.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),),
              ),
              widget.msg.sender==widget.currentUser?
              widget.msg.isSeenByReceiver?
              const Icon(Icons.check_circle_outlined,
                size: 16,
                color: Colors.blue,
              ):
              const Icon(Icons.check_circle_outlined,
                size: 16,
                color: Colors.grey,
              ):
                  const SizedBox()
            ],
          )
       ],
     )
    ],
    ),
    )

     : Container(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment:  widget.msg.sender==widget.currentUser
         ? MainAxisAlignment.end
         : MainAxisAlignment.start,

         children: [
          Column(
             crossAxisAlignment:  widget.msg.sender==widget.currentUser
         ? CrossAxisAlignment.end
         : CrossAxisAlignment.start,
        children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width *0.75),

                  decoration: BoxDecoration(
                      color: widget.msg.sender == widget.currentUser
                          ?Colors.lightGreen
                          :Colors.cyanAccent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: widget.msg.sender == widget.currentUser
                        ? const Radius.circular(20)
                        : const Radius.circular(2),

                    bottomRight: widget.msg.sender == widget.currentUser
                        ? const Radius.circular(20)
                        : const Radius.circular(2),

                    topLeft: const Radius.circular(10),
                    topRight: const Radius.circular(10))),

                child: Text(widget.msg.message,
                  style: TextStyle(
                      color: widget.msg.sender == widget.currentUser
                          ? Colors.white
                          : Colors.black),
                      ),
                   )
                 ]
               ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(formatDate(widget.msg.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),),
              ),
              widget.msg.sender==widget.currentUser?
              widget.msg.isSeenByReceiver?
              const Icon(Icons.check_circle_outlined,
                size: 16,
                color: Colors.blue,
              ):
              const Icon(Icons.check_circle_outlined,
                size: 16,
                color: Colors.grey,
              ):
                  const SizedBox()
            ],
          )
             ],
           )
          
        ],
      ),
    );
  }
}