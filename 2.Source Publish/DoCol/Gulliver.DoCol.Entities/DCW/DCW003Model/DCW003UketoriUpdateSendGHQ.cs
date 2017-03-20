using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gulliver.DoCol.Entities.DCW.DCW003Model
{
    public class DCW003UketoriUpdateSendGHQ
    {

        public string DocControlNo { get; set; }

        public string ShiireShuppinnTorokuNo { get; set; }

        public string ShopCd { get; set; }

        public string ChassisNo { get; set; }

        public string KeiCarFlg { get; set; }


        public string TorokuNo { get; set; }

        public DateTime? ShoruiLimitDate { get; set; }

        public string MasshoFlg { get; set; }

        public DateTime? ShakenLimitDate { get; set; }

        public string JishameiFlg { get; set; }

        public DateTime? DocNyukoDate { get; set; }
    }
}
