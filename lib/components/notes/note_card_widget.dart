import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/components/common/custom_slide.dart';
import 'package:noted_mobile/data/models/account/account.dart';
import 'package:noted_mobile/data/providers/account_provider.dart';
import 'package:noted_mobile/utils/constant.dart';
import 'package:noted_mobile/utils/string_extension.dart';
import 'package:openapi/openapi.dart';
import 'package:shimmer/shimmer.dart';

class NoteCard extends ConsumerStatefulWidget {
  const NoteCard({
    Key? key,
    this.color = kPrimaryColor,
    this.icon = Icons.description,
    this.onTap,
    this.displaySeeMore = false,
    this.baseColor,
    this.note,
  }) : super(key: key);

  const NoteCard.empty({
    Key? key,
  }) : this(
          key: key,
          note: null,
          color: null,
          icon: null,
          onTap: null,
          displaySeeMore: null,
          baseColor: null,
        );

  final V1Note? note;
  final Color? color;
  final IconData? icon;
  final bool? displaySeeMore;
  final Function()? onTap;
  final Color? baseColor;

  @override
  ConsumerState<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<NoteCard> {
  Widget buildCard(AsyncValue<Account?> account) {
    return CustomSlide(
      onTap: widget.onTap,
      actions: null,
      titleWidget: Text(
        widget.note!.title.capitalize(),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: widget.baseColor ?? Colors.black,
            ),
      ),
      subtitleWidget: Row(
        children: [
          const Icon(
            Icons.person,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(width: 5),
          account.when(
            data: (note) {
              if (note == null) {
                return Text(
                  'Error',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: widget.baseColor ?? Colors.black,
                      ),
                );
              }
              if (note.data.name == "") {
                return Text(
                  'Unknown',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: widget.baseColor ?? Colors.black,
                      ),
                );
              }
              return Text(
                note.data.name.capitalize(),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: widget.baseColor ?? Colors.black,
                    ),
              );
            },
            loading: () => Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[600]!,
              child: Container(
                height: 15,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                ),
              ),
            ),
            error: (error, stack) => Text(
              'Error',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: widget.baseColor ?? Colors.black,
                  ),
            ),
          ),
        ],
      ),
      withWidget: true,
      avatarWidget: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        height: 40,
        width: 40,
        child: Icon(
          widget.icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoadingCard = widget.note == null;

    if (isLoadingCard) {
      return const CustomSlide.empty();
    }

    final account = ref.watch(accountProvider(widget.note!.authorAccountId));

    return buildCard(account);
  }
}
