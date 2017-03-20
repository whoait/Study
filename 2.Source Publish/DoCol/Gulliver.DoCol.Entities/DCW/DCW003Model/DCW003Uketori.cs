using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gulliver.DoCol.Entities.DCW.DCW003Model
{
	public class DCW003Uketori
	{
		public List<DCW003UketoriDetail> UketoriDetail { get; set; }

		public string DocControlNo { get; set; }

		public string ShiireShuppinnTorokuNo { get; set; }

		public string UriageShuppinnTorokuNo { get; set; }

        public string ShopCd { get; set; }

        public string CarName { get; set; }

		public string ChassisNo { get; set; }

        public Single CcName { get; set; }  

		public string KeiCarFlg { get; set; }

        public DateTime? JishameiKanryoNyukoDate { get; set; }

        public int JoshaTeiinNum { get; set; }

		public DateTime? AaKaisaiDate { get; set; }

		public DateTime? DnSeiyakuDate { get; set; }

		public string TorokuNo { get; set; }

		public DateTime? ShoruiLimitDate { get; set; }

        public string MasshoFlg { get; set; }

        public DateTime? ShakenLimitDate { get; set; }

		public string JishameiFlg { get; set; }

        public string UriageCancelFlg { get; set; }

        public string ShiireCancelFlg { get; set; }

		public DateTime? MeihenShakenTorokuDate { get; set; }

        public DateTime? DocNyukoDate { get; set; }

        public int RowCount { get; set; }

        public int CheckRegister { get; set; }
	}
}
