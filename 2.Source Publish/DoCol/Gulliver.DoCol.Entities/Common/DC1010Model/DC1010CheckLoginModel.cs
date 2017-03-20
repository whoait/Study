//---------------------------------------------------------------------------
// System		: Seibi order
// Class Name	: DC1010CheckLoginModel
// Overview		: Check user login information.
// Designer		: PhuongPD@FPT
// Programmer	: NamNTP1@FPT
// Created Date	: 2015/04/08
//---------------------------------------------------------------------------
namespace Gulliver.DoCol.Entities.Common.DC1010Model
{
	/// <summary>
	/// Check user login information.
	/// </summary>
	public class DC1010CheckLoginModel
	{
		/// <summary>
		/// The ShainNo
		/// </summary>
		public string ShainNo { get; set; }

		/// <summary>
		/// The ShainName
		/// </summary>
		public string ShainName { get; set; }

		/// <summary>
		/// The AuthGroupCd
		/// </summary>
		public short AuthGroupCd { get; set; }

		/// <summary>
		/// The TempoCd
		/// </summary>
		public string TempoCd { get; set; }

		/// <summary>
		/// The ShoninRoleCd
		/// </summary>
		public short ShoninRoleCd { get; set; }

		/// <summary>
		/// The TempoName
		/// </summary>
		public string TempoName { get; set; }
	}
}