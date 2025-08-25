using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartPhone.Model.Requests;
using SmartPhone.Model.Responses;
using SmartPhone.Model.SearchObjects;
using SmartPhone.Services.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SmartPhone.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Technician,Administrator")]
    public class PhoneModelController : BaseCRUDController<PhoneModelResponse, PhoneModelSearchObject, PhoneModelUpsertRequest, PhoneModelUpsertRequest>
    {
        private readonly IPhoneModelService _phoneModelService;

        public PhoneModelController(IPhoneModelService phoneModelService) : base(phoneModelService)
        {
            _phoneModelService = phoneModelService;
        }

        [HttpGet("active")]
        public async Task<ActionResult<IEnumerable<PhoneModelResponse>>> GetActiveModels()
        {
            var models = await _phoneModelService.GetActiveModelsAsync();
            return Ok(models);
        }

        [HttpGet("brand/{brand}")]
        public async Task<ActionResult<IEnumerable<PhoneModelResponse>>> GetModelsByBrand(string brand)
        {
            var models = await _phoneModelService.GetModelsByBrandAsync(brand);
            return Ok(models);
        }

        [HttpGet("year/{year}")]
        public async Task<ActionResult<IEnumerable<PhoneModelResponse>>> GetModelsByYear(string year)
        {
            var models = await _phoneModelService.GetModelsByYearAsync(year);
            return Ok(models);
        }

        [HttpGet("series/{series}")]
        public async Task<ActionResult<IEnumerable<PhoneModelResponse>>> GetModelsBySeries(string series)
        {
            var models = await _phoneModelService.GetModelsBySeriesAsync(series);
            return Ok(models);
        }

        [HttpGet("brand/{brand}/model/{model}")]
        public async Task<ActionResult<PhoneModelResponse>> GetModelByBrandAndModel(string brand, string model)
        {
            var phoneModel = await _phoneModelService.GetModelByBrandAndModelAsync(brand, model);
            if (phoneModel == null)
                return NotFound();
            
            return Ok(phoneModel);
        }
    }
} 