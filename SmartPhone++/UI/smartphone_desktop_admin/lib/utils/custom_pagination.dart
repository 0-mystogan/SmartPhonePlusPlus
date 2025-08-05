import 'package:flutter/material.dart';

class CustomPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final Function(int)? onPageChanged;
  final bool showPageSizeSelector;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int?>? onPageSizeChanged;

  const CustomPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onNext,
    this.onPrevious,
    this.onPageChanged,
    this.showPageSizeSelector = false,
    this.pageSize = 10,
    this.pageSizeOptions = const [5, 10, 20, 50],
    this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
         return Container(
       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
       decoration: BoxDecoration(
         color: const Color(0xFFF5F5F5), // Match app background
         borderRadius: BorderRadius.circular(10),
         border: Border.all(
           color: Colors.grey.withOpacity(0.2),
           width: 1,
         ),
       ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Page Size Selector
          if (showPageSizeSelector) ...[
            Row(
              children: [
                Text(
                  'Show:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<int>(
                    value: pageSize,
                    underline: const SizedBox(),
                    items: pageSizeOptions.map((size) {
                      return DropdownMenuItem<int>(
                        value: size,
                        child: Text(
                          '$size',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: onPageSizeChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'entries',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
                         const SizedBox(width: 24),
          ],
          
          // Pagination Controls
          Row(
            children: [
              // Previous Button
              _buildPageButton(
                icon: Icons.chevron_left,
                onPressed: currentPage > 0 ? onPrevious : null,
                isActive: currentPage > 0,
                theme: theme,
              ),
              
              const SizedBox(width: 6),
              
              // Page Numbers
              ..._buildPageNumbers(context, theme),
              
              const SizedBox(width: 6),
              
              // Next Button
              _buildPageButton(
                icon: Icons.chevron_right,
                onPressed: currentPage < totalPages - 1 ? onNext : null,
                isActive: currentPage < totalPages - 1,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isActive,
    required ThemeData theme,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.primary : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey[400],
            size: 20,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context, ThemeData theme) {
    List<Widget> pageNumbers = [];
    int maxVisiblePages = 5;
    
    if (totalPages <= maxVisiblePages) {
      // Show all pages if total is small
      for (int i = 0; i < totalPages; i++) {
        pageNumbers.add(_buildPageNumber(context, i));
                 if (i < totalPages - 1) {
           pageNumbers.add(const SizedBox(width: 3));
         }
      }
    } else {
      // Show smart pagination for large numbers
      int startPage = (currentPage - 2).clamp(0, totalPages - maxVisiblePages);
      int endPage = (startPage + maxVisiblePages - 1).clamp(maxVisiblePages - 1, totalPages - 1);
      
      // First page
      if (startPage > 0) {
                 pageNumbers.add(_buildPageNumber(context, 0));
         pageNumbers.add(const SizedBox(width: 3));
         if (startPage > 1) {
           pageNumbers.add(_buildEllipsis());
           pageNumbers.add(const SizedBox(width: 3));
         }
      }
      
      // Middle pages
      for (int i = startPage; i <= endPage; i++) {
                 pageNumbers.add(_buildPageNumber(context, i));
         if (i < endPage) {
           pageNumbers.add(const SizedBox(width: 3));
         }
      }
      
      // Last page
             if (endPage < totalPages - 1) {
         pageNumbers.add(const SizedBox(width: 3));
         if (endPage < totalPages - 2) {
           pageNumbers.add(_buildEllipsis());
           pageNumbers.add(const SizedBox(width: 3));
         }
        pageNumbers.add(_buildPageNumber(context, totalPages - 1));
      }
    }
    
    return pageNumbers;
  }

  Widget _buildPageNumber(BuildContext context, int pageNumber) {
    final theme = Theme.of(context);
    bool isCurrentPage = pageNumber == currentPage;
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isCurrentPage ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentPage ? theme.colorScheme.primary : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: isCurrentPage
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onPageChanged?.call(pageNumber),
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              '${pageNumber + 1}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isCurrentPage ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      width: 32,
      height: 32,
      child: const Center(
        child: Text(
          '...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
