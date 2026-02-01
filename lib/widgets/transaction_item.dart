import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'avatar_image.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem(this.data, {super.key, this.onTap});
  
  final Map<String, dynamic> data;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
        decoration: BoxDecoration(
          color: AppColor.secondary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withAlpha(26),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AvatarImage(
              data['image'] ?? '',
              isSVG: false,
              width: 35,
              height: 35,
              radius: 50,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildNameAndAmount(),
                  const SizedBox(height: 2),
                  _buildDateAndType(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateAndType() {
    final isIncoming = data['type'] == 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          data['date'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isIncoming ? AppColor.green.withAlpha(26) : AppColor.red.withAlpha(26),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            isIncoming ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: isIncoming ? AppColor.green : AppColor.red,
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildNameAndAmount() {
    final isIncoming = data['type'] == 1;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            data['name'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '${isIncoming ? '+' : '-'}${data['price'] ?? ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isIncoming ? AppColor.green : AppColor.red,
          ),
        )
      ],
    );
  }
}
