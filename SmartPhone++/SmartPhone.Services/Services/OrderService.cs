using Microsoft.EntityFrameworkCore;
using SmartPhone.Services.Database;
using SmartPhone.Services.Interfaces;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;
using MapsterMapper;
using System;
using System.Linq;

namespace SmartPhone.Services.Services
{
    public class OrderService : BaseCRUDService<OrderResponse, OrderSearchObject, Order, OrderUpsertRequest, OrderUpsertRequest>, IOrderService
    {
        public OrderService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Order> ApplyFilter(IQueryable<Order> query, OrderSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.OrderNumber))
                query = query.Where(o => o.OrderNumber.Contains(search.OrderNumber));
            
            if (!string.IsNullOrEmpty(search.Status))
                query = query.Where(o => o.Status == search.Status);
            
            if (search.UserId.HasValue)
                query = query.Where(o => o.UserId == search.UserId.Value);
            
            if (search.OrderDateFrom.HasValue)
                query = query.Where(o => o.OrderDate >= search.OrderDateFrom.Value);
            
            if (search.OrderDateTo.HasValue)
                query = query.Where(o => o.OrderDate <= search.OrderDateTo.Value);
            
            if (search.MinTotalAmount.HasValue)
                query = query.Where(o => o.TotalAmount >= search.MinTotalAmount.Value);
            
            if (search.MaxTotalAmount.HasValue)
                query = query.Where(o => o.TotalAmount <= search.MaxTotalAmount.Value);
            
            if (!string.IsNullOrEmpty(search.ShippingFirstName))
                query = query.Where(o => o.ShippingFirstName.Contains(search.ShippingFirstName));
            
            if (!string.IsNullOrEmpty(search.ShippingLastName))
                query = query.Where(o => o.ShippingLastName.Contains(search.ShippingLastName));
            
            if (!string.IsNullOrEmpty(search.BillingFirstName))
                query = query.Where(o => o.BillingFirstName.Contains(search.BillingFirstName));
            
            if (!string.IsNullOrEmpty(search.BillingLastName))
                query = query.Where(o => o.BillingLastName.Contains(search.BillingLastName));

            return query;
        }



        protected override Order MapInsertToEntity(Order entity, OrderUpsertRequest request)
        {
            _mapper.Map(request, entity);
            entity.OrderDate = DateTime.UtcNow;
            entity.Status = "Pending";
            return entity;
        }

        protected override void MapUpdateToEntity(Order entity, OrderUpsertRequest request)
        {
            _mapper.Map(request, entity);
        }

        public override async Task<PagedResult<OrderResponse>> GetAsync(OrderSearchObject search)
        {
            var query = _context.Orders.AsQueryable();
            query = ApplyFilter(query, search);

            // Include navigation properties
            query = query
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var list = await query.ToListAsync();
            return new PagedResult<OrderResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public override async Task<OrderResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .FirstOrDefaultAsync(o => o.Id == id);
            
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public async Task<IEnumerable<OrderResponse>> GetOrdersByUserAsync(int userId)
        {
            var orders = await _context.Orders
                .Where(o => o.UserId == userId)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Include(o => o.User)
                .OrderByDescending(o => o.OrderDate)
                .ToListAsync();

            return orders.Select(MapToResponse).ToList();
        }

        public async Task<IEnumerable<OrderResponse>> GetOrdersByStatusAsync(string status)
        {
            var orders = await _context.Orders
                .Where(o => o.Status == status)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Include(o => o.User)
                .OrderByDescending(o => o.OrderDate)
                .ToListAsync();

            return orders.Select(MapToResponse).ToList();
        }

        public async Task<bool> UpdateOrderStatusAsync(int orderId, string status, string? notes = null)
        {
            var order = await _context.Orders.FindAsync(orderId);
            if (order == null)
                return false;

            order.Status = status;
            if (notes != null)
                order.Notes = notes;

            if (status == "Shipped")
                order.ShippedDate = DateTime.UtcNow;
            else if (status == "Delivered")
                order.DeliveredDate = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<decimal> GetTotalSalesAsync(DateTime fromDate, DateTime toDate)
        {
            return await _context.Orders
                .Where(o => o.OrderDate >= fromDate && o.OrderDate <= toDate && o.Status != "Cancelled")
                .SumAsync(o => o.TotalAmount);
        }

        public async Task<int> GetOrderCountAsync(DateTime fromDate, DateTime toDate)
        {
            return await _context.Orders
                .Where(o => o.OrderDate >= fromDate && o.OrderDate <= toDate && o.Status != "Cancelled")
                .CountAsync();
        }

        public async Task<OrderResponse?> GetOrderByNumberAsync(string orderNumber)
        {
            var order = await _context.Orders
                .Where(o => o.OrderNumber == orderNumber)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Include(o => o.User)
                .FirstOrDefaultAsync();

            return order != null ? MapToResponse(order) : null;
        }

        public async Task<OrderResponse> CreateOrderFromCartAsync(int userId, string orderNumber, decimal totalAmount, 
            string shippingFirstName, string shippingLastName, string shippingAddress, string shippingCity, 
            string shippingPostalCode, string shippingCountry, string shippingPhone, string? shippingEmail,
            string billingFirstName, string billingLastName, string billingAddress, string billingCity,
            string billingPostalCode, string billingCountry, string billingPhone, string? billingEmail)
        {
            // Get user's cart with items
            var cart = await _context.Carts
                .Include(c => c.CartItems)
                    .ThenInclude(ci => ci.Product)
                .FirstOrDefaultAsync(c => c.UserId == userId && c.IsActive);

            if (cart == null || !cart.CartItems.Any())
                throw new InvalidOperationException("Cart is empty or not found");

            // Calculate totals
            var subtotal = cart.CartItems.Sum(ci => ci.Quantity * (ci.Product.DiscountedPrice ?? ci.Product.Price));
            var taxAmount = 0m; // You can implement tax calculation logic here
            var shippingAmount = 0m; // You can implement shipping calculation logic here
            var discountAmount = 0m; // You can implement discount logic here

            // Create order
            var order = new Order
            {
                OrderNumber = orderNumber,
                OrderDate = DateTime.UtcNow,
                Subtotal = subtotal,
                TaxAmount = taxAmount,
                ShippingAmount = shippingAmount,
                DiscountAmount = discountAmount,
                TotalAmount = totalAmount,
                Status = "Pending",
                ShippingFirstName = shippingFirstName,
                ShippingLastName = shippingLastName,
                ShippingAddress = shippingAddress,
                ShippingCity = shippingCity,
                ShippingPostalCode = shippingPostalCode,
                ShippingCountry = shippingCountry,
                ShippingPhone = shippingPhone,
                ShippingEmail = shippingEmail,
                BillingFirstName = billingFirstName,
                BillingLastName = billingLastName,
                BillingAddress = billingAddress,
                BillingCity = billingCity,
                BillingPostalCode = billingPostalCode,
                BillingCountry = billingCountry,
                BillingPhone = billingPhone,
                BillingEmail = billingEmail,
                UserId = userId
            };

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            // Create order items from cart items
            var orderItems = cart.CartItems.Select(ci => new OrderItem
            {
                OrderId = order.Id,
                ProductId = ci.ProductId,
                Quantity = ci.Quantity,
                UnitPrice = ci.Product.DiscountedPrice ?? ci.Product.Price,
                TotalPrice = ci.Quantity * (ci.Product.DiscountedPrice ?? ci.Product.Price),
                ProductName = ci.Product.Name,
                ProductSKU = ci.Product?.SKU,
                CreatedAt = DateTime.UtcNow
            }).ToList();

            _context.OrderItems.AddRange(orderItems);
            await _context.SaveChangesAsync();

            // Clear the cart
            cart.IsActive = false;
            await _context.SaveChangesAsync();

            // Return the created order
            return await GetByIdAsync(order.Id);
        }
    }
}
