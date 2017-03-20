//---------------------------------------------------------------------------
// System		: Seibi order
// Class Name	: DC1010LoginModel
// Overview		: Get login auto mode information.
// Designer		: PhuongPD@FPT
// Programmer	: NamNTP1@FPT
// Created Date	: 2015/04/08
//---------------------------------------------------------------------------
namespace Gulliver.DoCol.Entities.Common.DC1010Model
{
	/// <summary>
	/// Get login auto mode information.
	/// </summary>
	public class DC1010LoginModel
	{
		/// <summary>
		/// shainNo from SOS system used for auto login mode.
		/// </summary>
		public string shainNo { get; set; }

		/// <summary>
		/// shainPassword from SOS system userd for auto login mode.
		/// </summary>
		public string shainPassword { get; set; }

		/// <summary>
		/// shain_cd from eBoard and TAPS system used for auto login mode.
		/// </summary>
		public string shain_cd { get; set; }

		/// <summary>
		/// shain_pw from eBoard and TAPS system used for auto login mode.
		/// </summary>
		public string shain_pw { get; set; }

		/// <summary>
		/// tenpo_cd from eBoard and TAPS system used for auto login mode.
		/// </summary>
		public string tenpo_cd { get; set; }

		/// <summary>
		/// tenpo_pw from eBoard and TAPS system used for auto login mode.
		/// </summary>
		public string tenpo_pw { get; set; }

		/// <summary>
		/// shodan_kanri_no from TAPS system used for auto login mode.
		/// </summary>
		public string shodan_kanri_no { get; set; }

		/// <summary>
		/// shodan_kanri_eda_no from TAPS system used for auto login mode.
		/// </summary>
		public string shodan_kanri_eda_no { get; set; }

		/// <summary>
		/// sharyo_order_no from TAPS system used for auto login mode.
		/// </summary>
		public string sharyo_order_no { get; set; }

		/// <summary>
		/// siire_no from TAPS system used for auto login mode.
		/// </summary>
		public string siire_no { get; set; }

		/// <summary>
		/// ordered_flg from TAPS system used for auto login mode.
		/// </summary>
		public string ordered_flg { get; set; }

		/// <summary>
		/// dn_shuppin_no from TAPS system used for auto login mode.
		/// </summary>
		public string dn_shuppin_no { get; set; }

		/// <summary>
		/// user_id from TAPS system used for auto login mode.
		/// </summary>
		public string user_id { get; set; }

		/// <summary>
		/// from_taps_hanbai from TAPS system used for auto login mode.
		/// </summary>
		public string from_taps_hanbai { get; set; }
	}
}