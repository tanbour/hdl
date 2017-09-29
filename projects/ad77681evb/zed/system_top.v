// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsabilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module system_top (

  inout   [14:0]  ddr_addr,
  inout   [ 2:0]  ddr_ba,
  inout           ddr_cas_n,
  inout           ddr_ck_n,
  inout           ddr_ck_p,
  inout           ddr_cke,
  inout           ddr_cs_n,
  inout   [ 3:0]  ddr_dm,
  inout   [31:0]  ddr_dq,
  inout   [ 3:0]  ddr_dqs_n,
  inout   [ 3:0]  ddr_dqs_p,
  inout           ddr_odt,
  inout           ddr_ras_n,
  inout           ddr_reset_n,
  inout           ddr_we_n,

  inout           fixed_io_ddr_vrn,
  inout           fixed_io_ddr_vrp,
  inout   [53:0]  fixed_io_mio,
  inout           fixed_io_ps_clk,
  inout           fixed_io_ps_porb,
  inout           fixed_io_ps_srstb,

  inout   [31:0]  gpio_bd,

  output          hdmi_out_clk,
  output          hdmi_vsync,
  output          hdmi_hsync,
  output          hdmi_data_e,
  output  [15:0]  hdmi_data,

  output          spdif,

  output          i2s_mclk,
  output          i2s_bclk,
  output          i2s_lrclk,
  output          i2s_sdata_out,
  input           i2s_sdata_in,


  inout           iic_scl,
  inout           iic_sda,
  inout   [ 1:0]  iic_mux_scl,
  inout   [ 1:0]  iic_mux_sda,

  input           otg_vbusoc,

  inout           ad7768_0_reset,
  inout           ad7768_0_sync_out,
  inout           ad7768_0_sync_in,
  inout   [ 3:0]  ad7768_0_gpio,

  inout           ad7768_1_reset,
  inout           ad7768_1_sync_out,
  inout           ad7768_1_sync_in,
  inout   [ 3:0]  ad7768_1_gpio,

  input           ad7768_0_mclk,
  input           ad7768_1_mclk,
  output          ad7768_mclk_return,

  input           ad7768_0_spi_miso,
  output          ad7768_0_spi_mosi,
  output          ad7768_0_spi_sclk,
  output          ad7768_0_spi_cs,
  input           ad7768_0_drdy,

  input           ad7768_1_spi_miso,
  output          ad7768_1_spi_mosi,
  output          ad7768_1_spi_sclk,
  output          ad7768_1_spi_cs,
  input           ad7768_1_drdy);

  // internal signals

  wire    [63:0]  gpio_i;
  wire    [63:0]  gpio_o;
  wire    [63:0]  gpio_t;
  wire    [ 1:0]  iic_mux_scl_i_s;
  wire    [ 1:0]  iic_mux_scl_o_s;
  wire            iic_mux_scl_t_s;
  wire    [ 1:0]  iic_mux_sda_i_s;
  wire    [ 1:0]  iic_mux_sda_o_s;
  wire            iic_mux_sda_t_s;
  wire            ad7768_0_mclk_s;
  wire            ad7768_1_mclk_s;

  // instantiations

  ad_data_clk #(.SINGLE_ENDED (1)) i_ad7768_0_mclk_receiver(
    .rst (1'b1),
    .locked (),
    .clk_in_p (ad7768_0_mclk),
    .clk_in_n (1'd0),
    .clk(ad7768_0_mclk_s));

  ad_data_clk #(.SINGLE_ENDED (1)) i_ad7768_1_mclk_receiver(
    .rst (1'b1),
    .locked (),
    .clk_in_p (ad7768_1_mclk),
    .clk_in_n (1'd0),
    .clk(ad7768_1_mclk_s));

  assign ad7768_mclk_return = ad7768_0_mclk_s;

  ad_iobuf #(
    .DATA_WIDTH(7)
  ) i_iobuf_ad7768_1_gpio (
    .dio_t(gpio_t[54:48]),
    .dio_i(gpio_o[54:48]),
    .dio_o(gpio_i[54:48]),
    .dio_p({ad7768_1_gpio,
            ad7768_1_sync_in,
            ad7768_1_sync_out,
            ad7768_1_reset}));

  ad_iobuf #(
    .DATA_WIDTH(7)
  ) i_iobuf_ad7768_0_gpio (
    .dio_t(gpio_t[38:32]),
    .dio_i(gpio_o[38:32]),
    .dio_o(gpio_i[38:32]),
    .dio_p({ad7768_0_gpio,
            ad7768_0_sync_in,
            ad7768_0_sync_out,
            ad7768_0_reset}));

  ad_iobuf #(
    .DATA_WIDTH(32)
  ) i_iobuf (
    .dio_t(gpio_t[31:0]),
    .dio_i(gpio_o[31:0]),
    .dio_o(gpio_i[31:0]),
    .dio_p(gpio_bd));

  ad_iobuf #(
    .DATA_WIDTH(2)
  ) i_iic_mux_scl (
    .dio_t({iic_mux_scl_t_s, iic_mux_scl_t_s}),
    .dio_i(iic_mux_scl_o_s),
    .dio_o(iic_mux_scl_i_s),
    .dio_p(iic_mux_scl));

  ad_iobuf #(
    .DATA_WIDTH(2)
  ) i_iic_mux_sda (
    .dio_t({iic_mux_sda_t_s, iic_mux_sda_t_s}),
    .dio_i(iic_mux_sda_o_s),
    .dio_o(iic_mux_sda_i_s),
    .dio_p(iic_mux_sda));

  system_wrapper i_system_wrapper (
    .ddr_addr (ddr_addr),
    .ddr_ba (ddr_ba),
    .ddr_cas_n (ddr_cas_n),
    .ddr_ck_n (ddr_ck_n),
    .ddr_ck_p (ddr_ck_p),
    .ddr_cke (ddr_cke),
    .ddr_cs_n (ddr_cs_n),
    .ddr_dm (ddr_dm),
    .ddr_dq (ddr_dq),
    .ddr_dqs_n (ddr_dqs_n),
    .ddr_dqs_p (ddr_dqs_p),
    .ddr_odt (ddr_odt),
    .ddr_ras_n (ddr_ras_n),
    .ddr_reset_n (ddr_reset_n),
    .ddr_we_n (ddr_we_n),
    .fixed_io_ddr_vrn (fixed_io_ddr_vrn),
    .fixed_io_ddr_vrp (fixed_io_ddr_vrp),
    .fixed_io_mio (fixed_io_mio),
    .fixed_io_ps_clk (fixed_io_ps_clk),
    .fixed_io_ps_porb (fixed_io_ps_porb),
    .fixed_io_ps_srstb (fixed_io_ps_srstb),
    .gpio_i (gpio_i),
    .gpio_o (gpio_o),
    .gpio_t (gpio_t),
    .hdmi_data (hdmi_data),
    .hdmi_data_e (hdmi_data_e),
    .hdmi_hsync (hdmi_hsync),
    .hdmi_out_clk (hdmi_out_clk),
    .hdmi_vsync (hdmi_vsync),
    .i2s_bclk (i2s_bclk),
    .i2s_lrclk (i2s_lrclk),
    .i2s_mclk (i2s_mclk),
    .i2s_sdata_in (i2s_sdata_in),
    .i2s_sdata_out (i2s_sdata_out),
    .iic_fmc_scl_io (iic_scl),
    .iic_fmc_sda_io (iic_sda),
    .iic_mux_scl_i (iic_mux_scl_i_s),
    .iic_mux_scl_o (iic_mux_scl_o_s),
    .iic_mux_scl_t (iic_mux_scl_t_s),
    .iic_mux_sda_i (iic_mux_sda_i_s),
    .iic_mux_sda_o (iic_mux_sda_o_s),
    .iic_mux_sda_t (iic_mux_sda_t_s),
    .ps_intr_00 (1'b0),
    .ps_intr_01 (1'b0),
    .ps_intr_02 (1'b0),
    .ps_intr_03 (1'b0),
    .ps_intr_04 (1'b0),
    .ps_intr_05 (1'b0),
    .ps_intr_06 (1'b0),
    .ps_intr_07 (1'b0),
    .ps_intr_08 (1'b0),
    .ps_intr_09 (1'b0),
    .otg_vbusoc (otg_vbusoc),
    .spdif (spdif),
    .adc1_spi_sdo (ad7768_0_spi_mosi),
    .adc1_spi_sdo_t (),
    .adc1_spi_sdi (ad7768_0_spi_miso),
    .adc1_spi_cs (ad7768_0_spi_cs),
    .adc1_spi_sclk (ad7768_0_spi_sclk),
    .adc1_data_ready (ad7768_0_drdy),
    .adc2_spi_sdo (ad7768_1_spi_mosi),
    .adc2_spi_sdo_t (),
    .adc2_spi_sdi (ad7768_1_spi_miso),
    .adc2_spi_cs (ad7768_1_spi_cs),
    .adc2_spi_sclk (ad7768_1_spi_sclk),
    .adc2_data_ready (ad7768_1_drdy));

endmodule

// ***************************************************************************
// ***************************************************************************