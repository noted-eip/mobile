import 'package:noted_mobile/data/note.dart';
import 'package:noted_mobile/data/note_block.dart';

const String kHeader1 = "Lorem ipsum dolor sit amet";
const String kHeader2 = "Sit amet consectetur adipiscing elit";
const String kParagraph1 =
    "Id leo in vitae turpis massa sed. Amet consectetur adipiscing elit pellentesque habitant morbi tristique senectus et. Vitae auctor eu augue ut lectus arcu.";
const String kParagraph2 =
    'Lobortis scelerisque fermentum dui faucibus in ornare quam viverra. Nisi scelerisque eu ultrices vitae auctor eu augue.';
const String kParagraph3 =
    'Mattis pellentesque id nibh tortor id aliquet lectus proin nibh. Varius duis at consectetur lorem donec massa sapien faucibus.';

Note kFakeNote1 = Note(
  id: 'N1',
  authorId: '1',
  title: 'Lorem Ipsum',
  blocks: [
    Block(
      id: '1',
      type: BlockType.heading1,
      text: kHeader1,
    ),
    Block(
      id: '2',
      type: BlockType.heading2,
      text: kHeader2,
    ),
    Block(
      id: '3',
      type: BlockType.paragraph,
      text: kParagraph1,
    ),
    Block(
      id: '4',
      type: BlockType.paragraph,
      text: kParagraph2,
    ),
    Block(
      id: '5',
      type: BlockType.paragraph,
      text: kParagraph3,
    ),
  ],
);

Note kFakeNote2 = Note(
  id: 'N2',
  authorId: '1',
  title: 'Lorem Ipsum 2',
  blocks: [
    Block(
      id: '1',
      type: BlockType.heading1,
      text: kHeader1,
    ),
    Block(
      id: '2',
      type: BlockType.heading2,
      text: kHeader2,
    ),
    Block(
      id: '3',
      type: BlockType.paragraph,
      text: kParagraph1,
    ),
    Block(
      id: '4',
      type: BlockType.paragraph,
      text: kParagraph2,
    ),
    Block(
      id: '5',
      type: BlockType.paragraph,
      text: kParagraph3,
    ),
  ],
);
