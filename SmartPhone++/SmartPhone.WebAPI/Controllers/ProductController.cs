using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;

namespace SmartPhone.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ProductController : BaseCRUDController<ProductResponse, ProductSearchObject, ProductUpsertRequest, ProductUpsertRequest>
    {
        private readonly IProductService _productService;

        public ProductController(IProductService productService) : base(productService)
        {
            _productService = productService;
        }

        [HttpGet("active")]
        public async Task<ActionResult<IEnumerable<ProductResponse>>> GetActiveProducts()
        {
            var products = await _productService.GetActiveProductsAsync();
            return Ok(products);
        }

        [HttpGet("featured")]
        public async Task<ActionResult<IEnumerable<ProductResponse>>> GetFeaturedProducts()
        {
            var products = await _productService.GetFeaturedProductsAsync();
            return Ok(products);
        }

        [HttpGet("category/{categoryId}")]
        public async Task<ActionResult<IEnumerable<ProductResponse>>> GetProductsByCategory(int categoryId)
        {
            var products = await _productService.GetProductsByCategoryAsync(categoryId);
            return Ok(products);
        }

        [HttpGet("low-stock")]
        public async Task<ActionResult<IEnumerable<ProductResponse>>> GetLowStockProducts()
        {
            var products = await _productService.GetLowStockProductsAsync();
            return Ok(products);
        }

        [HttpGet("brand/{brand}")]
        public async Task<ActionResult<IEnumerable<ProductResponse>>> GetProductsByBrand(string brand)
        {
            var products = await _productService.GetProductsByBrandAsync(brand);
            return Ok(products);
        }

        [HttpPut("{id}/stock")]
        public async Task<ActionResult> UpdateStockQuantity(int id, [FromBody] int quantity)
        {
            var result = await _productService.UpdateStockQuantityAsync(id, quantity);
            
            if (!result)
                return NotFound();

            return NoContent();
        }

        [HttpGet("{id}/availability")]
        public async Task<ActionResult<bool>> CheckAvailability(int id, [FromQuery] int requiredQuantity)
        {
            var isAvailable = await _productService.CheckProductAvailabilityAsync(id, requiredQuantity);
            return Ok(isAvailable);
        }



        [HttpGet("{id}/images")]
        public async Task<ActionResult<IEnumerable<ProductImageResponse>>> GetProductImages(int id)
        {
            var product = await _productService.GetByIdAsync(id);
            if (product == null)
                return NotFound();

            return Ok(product.ProductImages);
        }

        [HttpPost("{id}/images")]
        public async Task<ActionResult<ProductImageResponse>> AddProductImage(int id, [FromBody] ProductImageUpsertRequest request)
        {
            if (request.ProductId != id)
                return BadRequest("Product ID in URL must match ProductId in request");

            var product = await _productService.GetByIdAsync(id);
            if (product == null)
                return NotFound();

            // Create the image using the service
            var imageRequest = new ProductUpsertRequest
            {
                ProductImages = new List<ProductImageUpsertRequest> { request }
            };

            var updatedProduct = await _productService.UpdateAsync(id, imageRequest);
            if (updatedProduct == null)
                return NotFound();

            var newImage = updatedProduct.ProductImages.FirstOrDefault(pi => 
                pi.FileName == request.FileName);
            return CreatedAtAction(nameof(GetProductImages), new { id }, newImage);
        }

        [HttpPut("{id}/images/{imageId}")]
        public async Task<ActionResult<ProductImageResponse>> UpdateProductImage(int id, int imageId, [FromBody] ProductImageUpsertRequest request)
        {
            if (request.ProductId != id)
                return BadRequest("Product ID in URL must match ProductId in request");

            var product = await _productService.GetByIdAsync(id);
            if (product == null)
                return NotFound();

            var existingImage = product.ProductImages.FirstOrDefault(pi => pi.Id == imageId);
            if (existingImage == null)
                return NotFound();

            // Update the image
            request.ProductId = id;
            var imageRequest = new ProductUpsertRequest
            {
                ProductImages = new List<ProductImageUpsertRequest> { request }
            };

            var updatedProduct = await _productService.UpdateAsync(id, imageRequest);
            if (updatedProduct == null)
                return NotFound();

            var updatedImage = updatedProduct.ProductImages.FirstOrDefault(pi => pi.Id == imageId);
            return Ok(updatedImage);
        }

        [HttpDelete("{id}/images/{imageId}")]
        public async Task<ActionResult> DeleteProductImage(int id, int imageId)
        {
            var product = await _productService.GetByIdAsync(id);
            if (product == null)
                return NotFound();

            var existingImage = product.ProductImages.FirstOrDefault(pi => pi.Id == imageId);
            if (existingImage == null)
                return NotFound();

            // Remove the specific image by creating a new list without it
            var remainingImages = product.ProductImages
                .Where(pi => pi.Id != imageId)
                .Select(pi => new ProductImageUpsertRequest
                {
                    ImageData = pi.ImageData,
                    FileName = pi.FileName,
                    ContentType = pi.ContentType,
                    AltText = pi.AltText,
                    IsPrimary = pi.IsPrimary,
                    DisplayOrder = pi.DisplayOrder,
                    ProductId = id
                })
                .ToList();

            var imageRequest = new ProductUpsertRequest
            {
                ProductImages = remainingImages
            };

            var updatedProduct = await _productService.UpdateAsync(id, imageRequest);
            if (updatedProduct == null)
                return NotFound();

            return NoContent();
        }
    }
} 