import 'package:flutter/material.dart';
import 'package:chat_app/theme.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final int itemsPerPage;
  final int totalItems;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.itemsPerPage,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items info
          Text(
            'Showing ${_getStartRange()} - ${_getEndRange()} of $totalItems items',
            style: TextStyle(color: AppColors.textFaded),
          ),

          // Page navigation
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.keyboard_arrow_left),
                onPressed:
                    currentPage > 1
                        ? () => onPageChanged(currentPage - 1)
                        : null,
                color:
                    currentPage > 1 ? AppColors.secondary : AppColors.textFaded,
              ),

              // Page numbers
              _buildPageNumbers(),

              IconButton(
                icon: Icon(Icons.keyboard_arrow_right),
                onPressed:
                    currentPage < totalPages
                        ? () => onPageChanged(currentPage + 1)
                        : null,
                color:
                    currentPage < totalPages
                        ? AppColors.secondary
                        : AppColors.textFaded,
              ),
            ],
          ),

          // Items per page dropdown (optional future feature)
          SizedBox(width: 150),
        ],
      ),
    );
  }

  Widget _buildPageNumbers() {
    List<Widget> pageNumbers = [];

    // Logic to show limited page numbers with ellipsis for many pages
    if (totalPages <= 7) {
      // If 7 or fewer pages, show all
      for (int i = 1; i <= totalPages; i++) {
        pageNumbers.add(_buildPageButton(i));
      }
    } else {
      // Always show first page
      pageNumbers.add(_buildPageButton(1));

      // Show ellipsis or pages
      if (currentPage > 3) {
        pageNumbers.add(
          Text('...', style: TextStyle(color: AppColors.textFaded)),
        );
      }

      // Show current page and surrounding pages
      int start = (currentPage - 1) > 1 ? (currentPage - 1) : 2;
      int end =
          (currentPage + 1) < totalPages ? (currentPage + 1) : totalPages - 1;

      // Adjust to show at least 3 pages if possible
      if (start == 2 && end < 4) end = 4 > totalPages - 1 ? totalPages - 1 : 4;
      if (end == totalPages - 1 && start > totalPages - 3) {
        start = totalPages - 3 < 2 ? 2 : totalPages - 3;
      }

      for (int i = start; i <= end; i++) {
        pageNumbers.add(_buildPageButton(i));
      }

      // Show ellipsis or pages
      if (currentPage < totalPages - 2) {
        pageNumbers.add(
          Text('...', style: TextStyle(color: AppColors.textFaded)),
        );
      }

      // Always show last page
      pageNumbers.add(_buildPageButton(totalPages));
    }

    return Row(children: pageNumbers);
  }

  Widget _buildPageButton(int pageNumber) {
    final isCurrentPage = pageNumber == currentPage;

    return InkWell(
      onTap: isCurrentPage ? null : () => onPageChanged(pageNumber),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isCurrentPage ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isCurrentPage ? AppColors.secondary : AppColors.textFaded,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '$pageNumber',
            style: TextStyle(
              color: isCurrentPage ? Colors.white : AppColors.textFaded,
              fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  int _getStartRange() {
    return (currentPage - 1) * itemsPerPage + 1;
  }

  int _getEndRange() {
    int endRange = currentPage * itemsPerPage;
    return endRange > totalItems ? totalItems : endRange;
  }
}
