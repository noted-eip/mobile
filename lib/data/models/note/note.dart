
// class Note {
//   String id;
//   String authorId;
//   String groupId;
//   String title;
//   List<Block>? blocks;
//   DateTime? createdAt;
//   DateTime? modifiedAt;
//   DateTime? analysedAt;

//   Note({
//     required this.id,
//     required this.authorId,
//     required this.title,
//     required this.blocks,
//     this.analysedAt,
//     this.createdAt,
//     required this.groupId,
//     this.modifiedAt,
//   });

//   factory Note.fromApi(V1Note note) {
//     return Note(
//       id: note.id,
//       authorId: note.authorAccountId,
//       title: note.title,
//       groupId: note.groupId,
//       createdAt: note.createdAt,
//       modifiedAt: note.modifiedAt,
//       analysedAt: note.analyzedAt,
//       blocks: note.blocks?.map((e) => Block.fromApi(e)).toList(),
//     );
//   }

//   // Note to Api
//   V1Note toApi() {
//     return V1Note(
      
//       // id: id,
//       // authorAccountId: authorId,
//       // title: title,
//       // groupId: groupId,
//       // createdAt: createdAt,
//       // modifiedAt: modifiedAt,
//       // analyzedAt: analysedAt,
//       // blocks: blocks?.map((e) => e.toApi()).toList(),
//     ).rebuild((p0) => 
//       p0
//         ..id = id
//         ..authorAccountId = authorId
//         ..title = title
//         ..groupId = groupId
//         ..createdAt = createdAt
//         ..modifiedAt = modifiedAt
//         ..analyzedAt = analysedAt
//         ..blocks = blocks?.map((e) => e.toApi()).toList());
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'author_id': authorId,
//       'title': title,
//       'blocks': blocks == null
//           ? null
//           : blocks!.map((block) => block.toJson()).toList(),
//     };
//   }
// }
