using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Microcontroladores_II
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            Control.CheckForIllegalCrossThreadCalls = false;

            try //intenta hacer lo que hay dentro de este try
            {
                SPort.Open(); //abrir el puerto serial
            }
            catch (Exception ex)
            {
                MessageBox.Show("ERROR AL ABRIR EL PUERTO SERIAL\n\n" + ex); //Me muestra el error
                Application.Exit(); //cierra el programa
            }
            if (SPort.IsOpen)
            {
                //MessageBox.Show("TEXTO","TÍTULO");
                //A continuación se muestra la información del puerto (si se desea cambiar se debe hacer desde las propiedades del puerto)
                MessageBox.Show("El puerto " + SPort.PortName + " se abrió con una velocidad de " + SPort.BaudRate + "\nParidad: " + SPort.Parity + "\nNúmero de bits: " + SPort.DataBits + "\nBits de parada: " + SPort.StopBits, "Información de la conexión");
            }
        }


        private void SPort_DataReceived(object sender, System.IO.Ports.SerialDataReceivedEventArgs e)
        {
            int data = SPort.ReadByte();

            double voltaje = (data * 5.0) / 255;

            VoltsLabel.Text = voltaje.ToString();
        }
    }
}
