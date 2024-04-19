// import 'package:dart_quill_delta/src/delta/delta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_docs/common/widgets/loader.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/repository/auth_repository.dart';
import 'package:google_docs/repository/document_repository.dart';
import 'package:google_docs/repository/socket_repository.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({Key? key, required this.id}) : super(key: key);

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController = TextEditingController(text: 'Untitled Document');
  quill.QuillController? _controller ;
  ErrorModel? errorModel;
  SocketRepository socketRepository = SocketRepository();
  
  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();
    
    socketRepository.changeListener((data) {
      _controller?.compose(
          quill.Delta.fromJson(data['delta']),
          _controller?.selection?? const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.REMOTE,
      );
    });
  }

  void fetchDocumentData() async{
    errorModel = await ref.read(documentRepositoryProvider).getDocumentById(
        ref.read(userProvider)!.token,
        widget.id,
    );
    if(errorModel!.data != null){
      titleController.text = ( errorModel!.data as DocumentModel ).title ;
      _controller = quill.QuillController(
          document: errorModel!.data.content.isEmpty
              ? quill.Document()
              : quill.Document.fromDelta(
                  quill.Delta.fromJson(errorModel!.data.content),
          ) ,
          selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() { });
    }

    _controller!.document.changes.listen((event) {
      if(event.item3 == quill.ChangeSource.LOCAL){
        Map<String,dynamic> map = {
          'delta' : event.item2,
          'room' : widget.id,
        };
        socketRepository.typing(map);
      }
    });

  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  void updateTitle(WidgetRef ref , String title) {
    ref.read(documentRepositoryProvider).updateTitle(
        token: ref.read(userProvider)!.token,
        id: widget.id,
        title: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    if(_controller == null ){
      return const Scaffold(
        body: Loader(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
                onPressed: (){},
                icon: const Icon(Icons.lock , color: kWhiteColor,size: 16,),
                label: const Text('Share', style: TextStyle(color: kWhiteColor),),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlueColor
              ),
            ),
          )
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Row(
            children: [
              Image.asset('assets/images/docs-logo.png',height: 40,),
              const SizedBox(width: 10,),
              SizedBox(
                width: 160,
                child: TextField(
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kBlueColor,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 10)
                  ),
                  controller: titleController,
                  onSubmitted: (value) => updateTitle(ref , value),
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: kGreyColor,
                width: 0.1,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            quill.QuillToolbar.simple(
              configurations: quill.QuillSimpleToolbarConfigurations(
                controller: _controller!,
                sharedConfigurations: const quill.QuillSharedConfigurations(
                  locale: Locale('de'),
                ),
              ),

            ),
            const SizedBox(height: 10,),
            Expanded(
              child: SizedBox(
                width: 750,
                child: Card(
                  color: kWhiteColor,
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: quill.QuillEditor.basic(
                      configurations: quill.QuillEditorConfigurations(
                        controller: _controller!,
                        readOnly: false,
                        sharedConfigurations: const quill.QuillSharedConfigurations(
                          locale: Locale('de'),
                        ),
                      ),

                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
