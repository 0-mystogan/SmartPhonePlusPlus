using SmartPhone.Services.Database;
using SmartPhone.Model.Responses;
using SmartPhone.Model.Requests;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic; // Added for List<CartItemResponse>

namespace SmartPhone.Services.Services
{
    public class CartService : BaseCRUDService<CartResponse, CartSearchObject, Cart, CartUpsertRequest, CartUpsertRequest>, ICartService
    {
        public CartService(SmartPhoneDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Cart> ApplyFilter(IQueryable<Cart> query, CartSearchObject search)
        {
            if (search.UserId.HasValue)
                query = query.Where(c => c.UserId == search.UserId.Value);

            if (search.IsActive.HasValue)
                query = query.Where(c => c.IsActive == search.IsActive.Value);

            if (search.CreatedFrom.HasValue)
                query = query.Where(c => c.CreatedAt >= search.CreatedFrom.Value);

            if (search.CreatedTo.HasValue)
                query = query.Where(c => c.CreatedAt <= search.CreatedTo.Value);

            if (!string.IsNullOrEmpty(search.FTS))
                query = query.Where(c => c.User.Username.Contains(search.FTS) || 
                                       c.User.Email.Contains(search.FTS));

            return query;
        }

        public override async Task<PagedResult<CartResponse>> GetAsync(CartSearchObject search)
        {
            var query = _context.Carts.AsQueryable();
            query = ApplyFilter(query, search);

            // Always include User and CartItems for mapping
            query = query.Include(c => c.User)
                        .Include(c => c.CartItems)
                            .ThenInclude(ci => ci.Product)
                                .ThenInclude(p => p.ProductImages);

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
            
            return new PagedResult<CartResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public override async Task<CartResponse?> GetByIdAsync(int id)
        {
            var cart = await _context.Carts
                .Include(c => c.User)
                .Include(c => c.CartItems)
                    .ThenInclude(ci => ci.Product)
                        .ThenInclude(p => p.ProductImages)
                .FirstOrDefaultAsync(c => c.Id == id);

            return cart != null ? MapToResponse(cart) : null;
        }

        protected override async Task BeforeInsert(Cart entity, CartUpsertRequest request)
        {
            // Set creation timestamp
            entity.CreatedAt = System.DateTime.UtcNow;
            entity.IsActive = true;
            
            // Ensure UserId is set
            if (request.UserId <= 0)
                throw new System.ArgumentException("UserId is required");
            
            entity.UserId = request.UserId;
            
            // Log for debugging
            System.Diagnostics.Debug.WriteLine($"Creating cart for user {request.UserId}");
            System.Diagnostics.Debug.WriteLine($"Cart entity - UserId: {entity.UserId}, IsActive: {entity.IsActive}, CreatedAt: {entity.CreatedAt}");
        }

        protected override async Task BeforeUpdate(Cart entity, CartUpsertRequest request)
        {
            // Set update timestamp
            entity.UpdatedAt = System.DateTime.UtcNow;
            
            // Ensure UserId cannot be changed
            if (request.UserId != entity.UserId)
                throw new System.ArgumentException("UserId cannot be changed");
        }

        protected override CartResponse MapToResponse(Cart entity)
        {
            // Ensure User and CartItems are loaded
            if (entity.User == null)
            {
                _context.Entry(entity).Reference(c => c.User).Load();
            }
            if (entity.CartItems == null)
            {
                _context.Entry(entity).Collection(c => c.CartItems).Load();
            }
            
            // Ensure Product and ProductImages are loaded for each CartItem
            if (entity.CartItems != null)
            {
                foreach (var cartItem in entity.CartItems)
                {
                    if (cartItem.Product == null)
                    {
                        _context.Entry(cartItem).Reference(ci => ci.Product).Load();
                    }
                    if (cartItem.Product?.ProductImages == null)
                    {
                        _context.Entry(cartItem.Product).Collection(p => p.ProductImages).Load();
                    }
                }
            }
            
            // Use Mapster to handle the mapping, including CartItems
            var response = _mapper.Map<CartResponse>(entity);
            return response;
        }

        public async Task<CartResponse?> GetByUserIdAsync(int userId)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"GetByUserIdAsync called for user {userId}");
                
                // First, let's check if there are any carts at all for this user
                var allCartsForUser = await _context.Carts
                    .Where(c => c.UserId == userId)
                    .ToListAsync();
                
                System.Diagnostics.Debug.WriteLine($"Total carts found for user {userId}: {allCartsForUser.Count}");
                foreach (var c in allCartsForUser)
                {
                    System.Diagnostics.Debug.WriteLine($"Cart ID: {c.Id}, UserId: {c.UserId}, IsActive: {c.IsActive}, CreatedAt: {c.CreatedAt}");
                }
                
                // Now check for active carts
                var activeCartsForUser = await _context.Carts
                    .Where(c => c.UserId == userId && c.IsActive)
                    .ToListAsync();
                
                System.Diagnostics.Debug.WriteLine($"Active carts found for user {userId}: {activeCartsForUser.Count}");
                
                var cart = await _context.Carts
                    .Include(c => c.User)
                    .Include(c => c.CartItems)
                        .ThenInclude(ci => ci.Product)
                            .ThenInclude(p => p.ProductImages)
                    .FirstOrDefaultAsync(c => c.UserId == userId && c.IsActive);

                System.Diagnostics.Debug.WriteLine($"Cart found: {cart != null}");
                if (cart != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Cart ID: {cart.Id}, User ID: {cart.UserId}");
                    System.Diagnostics.Debug.WriteLine($"CartItems count: {cart.CartItems?.Count ?? 0}");
                    if (cart.CartItems != null)
                    {
                        foreach (var item in cart.CartItems)
                        {
                            System.Diagnostics.Debug.WriteLine($"CartItem: ID={item.Id}, ProductId={item.ProductId}, Quantity={item.Quantity}");
                        }
                    }
                }

                return cart != null ? MapToResponse(cart) : null;
            }
            catch (Exception ex)
            {
                // Log the exception for debugging
                System.Diagnostics.Debug.WriteLine($"Error in GetByUserIdAsync: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                throw;
            }
        }

        /// <summary>
        /// Get or create a cart for a specific user
        /// </summary>
        public async Task<CartResponse> GetOrCreateCartForUserAsync(int userId)
        {
            var existingCart = await GetByUserIdAsync(userId);
            if (existingCart != null)
                return existingCart;

            // Create new cart for user
            var cartRequest = new CartUpsertRequest { UserId = userId };
            var newCart = await CreateAsync(cartRequest);
            return newCart;
        }

        /// <summary>
        /// Deactivate a cart (soft delete)
        /// </summary>
        public async Task<bool> DeactivateCartAsync(int cartId, int userId)
        {
            var cart = await _context.Carts
                .FirstOrDefaultAsync(c => c.Id == cartId && c.UserId == userId);

            if (cart == null)
                return false;

            cart.IsActive = false;
            cart.UpdatedAt = System.DateTime.UtcNow;
            
            await _context.SaveChangesAsync();
            return true;
        }

        /// <summary>
        /// Get cart summary for a user
        /// </summary>
        public async Task<CartSummaryResponse> GetCartSummaryAsync(int userId)
        {
            var cart = await GetByUserIdAsync(userId);
            if (cart == null)
                return new CartSummaryResponse
                {
                    UserId = userId,
                    TotalItems = 0,
                    TotalAmount = 0
                };

            var totalItems = cart.CartItems?.Sum(ci => ci.Quantity) ?? 0;
            var totalAmount = cart.CartItems?.Sum(ci => ci.TotalPrice) ?? 0;

            return new CartSummaryResponse
            {
                UserId = userId,
                CartId = cart.Id,
                TotalItems = totalItems,
                TotalAmount = totalAmount
            };
        }

        /// <summary>
        /// Add item to cart or increment quantity if item already exists
        /// </summary>
        public async Task<CartResponse> AddItemToCartAsync(int userId, int productId, int quantity)
        {
            // Get or create cart for user
            var cart = await GetOrCreateCartForUserAsync(userId);
            
            // Check if CartItem already exists for this CartId and ProductId
            var existingCartItem = await _context.CartItems
                .FirstOrDefaultAsync(ci => ci.CartId == cart.Id && ci.ProductId == productId);

            if (existingCartItem != null)
            {
                // If it exists: increment Quantity and set UpdatedAt
                existingCartItem.Quantity += quantity;
                existingCartItem.UpdatedAt = System.DateTime.UtcNow;
            }
            else
            {
                // If not: create a new CartItem
                var newCartItem = new CartItem
                {
                    CartId = cart.Id,
                    ProductId = productId,
                    Quantity = quantity,
                    CreatedAt = System.DateTime.UtcNow
                };
                
                _context.CartItems.Add(newCartItem);
            }

            // Save changes to DbContext
            await _context.SaveChangesAsync();
            
            // Return the updated Cart
            return await GetByUserIdAsync(userId);
        }

        /// <summary>
        /// Update item quantity in cart or remove if quantity <= 0
        /// </summary>
        public async Task<CartResponse> UpdateItemQuantityAsync(int userId, int productId, int quantity)
        {
            var cart = await GetByUserIdAsync(userId);
            if (cart == null)
                throw new System.ArgumentException("No active cart found for user");

            var existingCartItem = await _context.CartItems
                .FirstOrDefaultAsync(ci => ci.CartId == cart.Id && ci.ProductId == productId);

            if (existingCartItem == null)
                throw new System.ArgumentException("Product not found in cart");

            if (quantity <= 0)
            {
                // Remove the item if quantity <= 0
                _context.CartItems.Remove(existingCartItem);
            }
            else
            {
                // Update Quantity and UpdatedAt
                existingCartItem.Quantity = quantity;
                existingCartItem.UpdatedAt = System.DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
            
            return await GetByUserIdAsync(userId);
        }

        /// <summary>
        /// Remove item from cart
        /// </summary>
        public async Task<CartResponse> RemoveItemFromCartAsync(int userId, int productId)
        {
            var cart = await GetByUserIdAsync(userId);
            if (cart == null)
                throw new System.ArgumentException("No active cart found for user");

            var existingCartItem = await _context.CartItems
                .FirstOrDefaultAsync(ci => ci.CartId == cart.Id && ci.ProductId == productId);

            if (existingCartItem == null)
                throw new System.ArgumentException("Product not found in cart");

            // Remove the CartItem
            _context.CartItems.Remove(existingCartItem);
            await _context.SaveChangesAsync();
            
            return await GetByUserIdAsync(userId);
        }

        /// <summary>
        /// Get cart items by cart ID (helper method for clear cart functionality)
        /// </summary>
        public async Task<List<CartItem>> GetCartItemsAsync(int cartId)
        {
            return await _context.CartItems
                .Where(ci => ci.CartId == cartId)
                .ToListAsync();
        }
    }
}
