﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudyFW.MVC4.Entities.Common
{
	public class TorihikiModel
	{
		public string OrderNo { get; set; } //(varchar(20), not null)
		public string OrderDenpyoNo { get; set; } //(varchar(20), null)
		public string EstimationDenpyoNo { get; set; } //(varchar(20), null)
		public string DeliveryDenpyoNo { get; set; } //(varchar(20), null)
		public string BillingDenpyoNo { get; set; } //(varchar(20), null)
		public string KaishaCd { get; set; } //(char(5), null)
		public string KaishaName { get; set; } //(nvarchar(400), null)
		public string BushoCd { get; set; } //(char(3), null)
		public string BushoName { get; set; } //(nvarchar(400), null)
		public string OrderTempoTantoshaCd { get; set; } //(varchar(10), null)
		public string OrderTempoTantoshaName { get; set; } //(nvarchar(100), null)
		public string OrderTempoCd { get; set; } //(char(6), null)
		public string OrderTempoName { get; set; } //(varchar(60), null)
		public string OrderTempoaddress { get; set; } //(nvarchar(200), null)
		public string OrderTempoTel { get; set; } //(varchar(13), null)
		public string OrderTempofax { get; set; } //(varchar(13), null)
		public string HiyoFutanTempoCd { get; set; } //(varchar(6), null)
		public string HiyoFutanTempoName { get; set; } //(varchar(60), null)
		public int BlockCd { get; set; } //(int, null)
		public string BlockName { get; set; } //(varchar(20), null)
		public string CustomerCd { get; set; } //(varchar(16), null)
		public string CustomerName { get; set; } //(nvarchar(100), null)
		public string Customeraddress { get; set; } //(nvarchar(200), null)
		public string CustomerTel { get; set; } //(varchar(13), null)
		public string RenrakusakiKaisha { get; set; } //(nvarchar(400), null)
		public string RenrakusakiBusho { get; set; } //(nvarchar(400), null)
		public string RenrakusakiTel { get; set; } //(varchar(13), null)
		public string Renrakusakifax { get; set; } //(varchar(13), null)
		public int HonbuJuhachuCarId { get; set; } //(int, null)
		public string CarId { get; set; } //(char(16), null)
		public string CarSubId { get; set; } //(char(3), null)
		public string JuchuNo { get; set; } //(char(20), null)
		public int JuchumeisaiNo { get; set; } //(int, null)
		public string BBNo { get; set; } //(nvarchar(14), null)
		public DateTime? JuchuDate { get; set; } //(datetime, null)
		public string goyoumeiCd { get; set; } //(char(3), null)
		public long JuchuPrice { get; set; } //(bigint, null)
		public int JuchuStatus { get; set; } //(int, null)
		public string RikujiName { get; set; } //(nvarchar(20), null)
		public string TourokuNo1 { get; set; } //(varchar(3), null)
		public string TourokuNo2 { get; set; } //(varchar(2), null)
		public string TourokuNo3 { get; set; } //(varchar(4), null)
		public string GlvMakerCd { get; set; } //(char(3), null)
		public string MakerName { get; set; } //(nvarchar(50), null)
		public string CarName { get; set; } //(nvarchar(100), null)
		public byte ShokkendakokuKbn { get; set; } //(tinyint, null)
		public string ShadaiNo { get; set; } //(varchar(24), null)
		public int ShonendoTourokuyear { get; set; } //(int, null)
		public string Katashiki { get; set; } //(varchar(24), null)
		public string EnginKatashiki { get; set; } //(varchar(128), null)
		public string KatashikiShiteiNo { get; set; } //(varchar(5), null)
		public string ruibetsuKbn { get; set; } //(varchar(4), null)
		public int CarWeight { get; set; } //(int, null)
		public int CarGrossWeight { get; set; } //(int, null)
		public string GradeName { get; set; } //(char(9), null)
		public bool KokusanGaishaFlg { get; set; } //(bit, null)
		public string ColorCd { get; set; } //(varchar(100), null)
		public string ConvOriginalExteriorCurrentColorName { get; set; } //(nvarchar(127), null)
		public string InteriorColorCd { get; set; } //(varchar(8), null)
		public string ConvOriginalInteriorColorName { get; set; } //(nvarchar(127), null)
		public string Caruse { get; set; } //(nvarchar(2), null)
		public Single CCReal { get; set; } //(varchar(20), null)
		public string JikayoJigyoyoKbn { get; set; } //(nvarchar(3), null)
		public string KeijoCd { get; set; } //(char(3), null)
		public string DNNo { get; set; } //(char(8), null)
		public string AANo { get; set; } //(varchar(5), null)
		public DateTime? DNRakusatsuDate { get; set; } //(datetime, null)
		public DateTime? AArakusatsuDate { get; set; } //(datetime, null)
		public string RakusatsuTempoCd { get; set; } //(char(6), null)
		public string RakusatsuTempoName { get; set; } //(nvarchar(100), null)
		public DateTime? ShakenManryoDate { get; set; } //(datetime, null)
		public string ShiireNo { get; set; } //(varchar(10), null)
		public int MileageKm { get; set; } //(int, null)
		public decimal CarLength { get; set; } //(decimal(8,0), null)
		public decimal CarWidth { get; set; } //(decimal(8,0), null)
		public decimal CarHeight { get; set; } //(decimal(8,0), null)
		public DateTime? NoshaRequestDate { get; set; } //(datetime, null)
		public string IraiBiko { get; set; } //(nvarchar(400), null)
		public string SeibiKbnCd { get; set; } //(varchar(5), null)
		public string SagyoIraiKbn { get; set; } //(varchar(5), null)
		public string TaishoKbn { get; set; } //(varchar(5), null)
		public string TorihikiKbn { get; set; } //(char(2), null)
		public string OrderStatus { get; set; } //(varchar(4), null)
		public string SeibiStatus { get; set; } //(varchar(4), null)
		public byte EstimateShoninStatus { get; set; } //(tinyint, null)
		public DateTime? EstimateStatusDate { get; set; } //(datetime, null)
		public byte DeliveryShoninStatus { get; set; } //(tinyint, null)
		public DateTime? DeliveryStatusDate { get; set; } //(datetime, null)
		public byte BillingShoninStatus { get; set; } //(tinyint, null)
		public DateTime? BillingStatusDate { get; set; } //(datetime, null)
		public byte HonbuJuhachuStatus { get; set; } //(tinyint, null)
		public bool SeibiCancelFlg { get; set; } //(bit, null)
		public bool IraiCancelFlg { get; set; } //(bit, null)
		public bool OrderCancelFlg { get; set; } //(bit, null)
		public string CancelReason { get; set; } //(nvarchar(400), null)
		public DateTime? CancelDate { get; set; } //(datetime, null)
		public DateTime? OrderCancelDate { get; set; } //(datetime, null)
		public DateTime? NoshaDate { get; set; } //(datetime, null)
		public DateTime? CarHikitoriRequestDate { get; set; } //(datetime, null)
		public DateTime? CarDeliveryRequestDate { get; set; } //(datetime, null)
		public DateTime? RikusoTochakuPlanDate { get; set; } //(datetime, null)
		public DateTime? RikusoTochakuDate { get; set; } //(datetime, null)
		public string RikusoTehaiTantosha { get; set; } //(varchar(10), null)
		public string EstimationRequestTantoshaCd { get; set; } //(varchar(10), null)
		public DateTime? EstimationRequestDate { get; set; } //(datetime, null)
		public string KojoNyukoTantoshaName { get; set; } //(nvarchar(100), null)
		public DateTime? KojoNyukoDate { get; set; } //(datetime, null)
		public string EstimationTantoshaName { get; set; } //(nvarchar(100), null)
		public string DeliveryTantoshaName { get; set; } //(nvarchar(100), null)
		public DateTime? DeliveryHakkoDate { get; set; } //(datetime, null)
		public string DeliveryTenchoSyoninTantoshaCd { get; set; } //(varchar(10), null)
		public DateTime? DeliveryTenchoSyoninDate { get; set; } //(datetime, null)
		public string DeliveryHonbuSyoninTantoshaCd { get; set; } //(varchar(10), null)
		public DateTime? DeliveryHonbuSyoninDate { get; set; } //(datetime, null)
		public string BillingTantoshaName { get; set; } //(nvarchar(100), null)
		public DateTime? BillingHakkoDate { get; set; } //(datetime, null)
		public DateTime? NyukinRequestDate { get; set; } //(datetime, null)
		public string BillingHonbuSyoninTantoshaCd { get; set; } //(varchar(10), null)
		public DateTime? BillingHonbuSyoninDate { get; set; } //(datetime, null)
		public string OrderTantoshaCd { get; set; } //(varchar(10), null)
		public DateTime? OrderDate { get; set; } //(datetime, null)
		public string EstimationshutokuTantoshaCd { get; set; } //(varchar(10), null)
		public DateTime? EstimationHakkoDate { get; set; } //(datetime, null)
		public string EstimationInputTantoshaCd { get; set; } //(varchar(10), null)
		public DateTime? EstimationInputDate { get; set; } //(datetime, null)
		public string OrderInputTantoshaCd { get; set; } //(varchar(10), null)
		public DateTime? OrderInputDate { get; set; } //(datetime, null)
		public string DeliveryInputTantoshaCd { get; set; } //(varchar(10), null)
		public DateTime? DeliveryInputDate { get; set; } //(datetime, null)
		public string BillingInputTantoshaCd { get; set; } //(varchar(10), null)
		public DateTime? BillingInputDate { get; set; } //(datetime, null)
		public DateTime? ShiharaiDate { get; set; } //(datetime, null)
		public DateTime? ShiharaiYoteiDate { get; set; } //(datetime, null)
		public DateTime? DeliveryKeijoDate { get; set; } //(datetime, null)
		public string HonbuTantoshaCd { get; set; } //(varchar(10), null)
		public string HonbuTantoshaName { get; set; } //(nvarchar(100), null)
		public int OrderPriceincludeTax { get; set; } //(int, null)
		public int DeliveryPriceincludeTax { get; set; } //(int, null)
		public int BillingPriceincludeTax { get; set; } //(int, null)
		public bool DeliveryTenchoSyoninFlg { get; set; } //(bit, null)
		public bool SystemDonyuFlg { get; set; } //(bit, null)
		public bool NinteiKojoFlg { get; set; } //(bit, null)
		public bool InputEstimationFlg { get; set; } //(bit, null)
		public bool InputOrderFlg { get; set; } //(bit, null)
		public bool TapsOrderFlg { get; set; } //(bit, null)
		public bool DelFlg { get; set; } //(bit, null)
		public string CreateUser { get; set; } //(varchar(10), null)
		public DateTime? CreateDate { get; set; } //(datetime, null)
		public string UpDateUser { get; set; } //(varchar(10), null)
		public DateTime? UpDateDate { get; set; } //(datetime, null)

		// Left join T_ESTIMATION get status save daff in H2050
		public Int16 ShoninStatus { get; set; }

		// Left join T_Car_Info
		public string ShopOwnerId { get; set; }

		// Check input work content info H2010
		public bool FlgInputWorkContent { get; set; }
		public DateTime? InputDate { get; set; }
	}

}
