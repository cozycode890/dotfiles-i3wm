#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Time::HiRes qw(usleep);

# ── Theme
my $BG_BAR    = $ENV{BG_BAR}    // '#1F2335';
my $SEG_BG    = $ENV{SEG_BG}    // '#7AA2F7';    # cyan pill
my $FG_DARK   = $ENV{FG_DARK}   // '#2e3440';    # text on cyan
my $FG_DIM    = $ENV{FG_DIM}    // '#3b4252';    # subtle text
my $FG_TEXT   = $ENV{FG_TEXT}   // '#272e33';    # subtle text
my $SEP_LEFT  = $ENV{SEP_LEFT}  // '󱎕';
my $SEP_RIGHT = $ENV{SEP_RIGHT} // '';

my $ICON = $ENV{ICON_CPU} // '';                # nf-fa-microchip

my $SIZE_SEP  = $ENV{SIZE_SEP}  // 'xx-large';
my $SIZE_ICON = $ENV{SIZE_ICON} // 'medium';
my $SIZE_TEXT = $ENV{SIZE_TEXT} // 'medium';
my $RISE_TEXT = $ENV{RISE_TEXT} // '6pt';
my $RISE_ICON = $ENV{RISE_ICON} // '5pt';

# ── Options / thresholds ──────────────────────────────────────────────────────
my $t_warn     = defined $ENV{T_WARN}   ? $ENV{T_WARN}   : 50;
my $t_crit     = defined $ENV{T_CRIT}   ? $ENV{T_CRIT}   : 80;
my $decimals   = defined $ENV{DECIMALS} ? $ENV{DECIMALS} : 1;
my $label      = $ENV{LABEL}        // '';    # giữ để tương thích với config cũ
my $color_ok   = $ENV{COLOR_NORMAL} // '#A3BE8C';
my $color_warn = $ENV{COLOR_WARN}   // '#D08770';
my $color_crit = $ENV{COLOR_CRIT}   // '#BF616A';

binmode STDOUT, ':encoding(UTF-8)';

# ── Click actions (BLOCK_BUTTON) ──────────────────────────────────────────────
if ( exists $ENV{BLOCK_BUTTON} && $ENV{BLOCK_BUTTON} eq '1' ) {
    system( 'bash', '-lc',
            'command -v btop >/dev/null && setsid -f btop >/dev/null 2>&1 || '
          . 'command -v htop >/dev/null && setsid -f htop >/dev/null 2>&1 || '
          . 'command -v gnome-system-monitor >/dev/null && setsid -f gnome-system-monitor >/dev/null 2>&1'
    );
}

# ── CPU usage helpers ─────────────────────────────────────────────────────────
sub cpu_usage_mpstat {
    $ENV{LC_ALL} = 'C';
    open my $fh, '-|', 'mpstat 1 1' or return undef;
    my $usage;
    while ( my $line = <$fh> ) {

        # Dòng tổng thường kết thúc bằng %idle; lấy số cuối cùng
        if ( $line =~ /\s(\d+(?:\.\d+)?)\s*$/ ) {
            my $idle = $1;

            # lọc những dòng rõ ràng có từ %idle
            next unless $line =~ /%idle/;
            $usage = 100 - $idle;
            last;
        }
    }
    close $fh;
    return $usage;
}

sub read_proc_stat {
    open my $fh, '<', '/proc/stat' or return undef;
    my $line = <$fh>;
    close $fh;
    return undef unless defined $line;

    # cpu  user nice system idle iowait irq softirq steal guest guest_nice
    my @f = split /\s+/, $line;

    # Bỏ "cpu"
    shift @f;
    my ( $user, $nice, $sys, $idle, $iowait, $irq, $softirq, $steal ) =
      @f[ 0 .. 7 ];
    $iowait  //= 0;
    $irq     //= 0;
    $softirq //= 0;
    $steal   //= 0;
    my $idle_all = $idle + $iowait;
    my $non_idle = $user + $nice + $sys + $irq + $softirq + $steal;
    my $total    = $idle_all + $non_idle;
    return ( $total, $idle_all );
}

sub cpu_usage_procstat {
    my ( $t1, $i1 ) = read_proc_stat();
    return undef unless defined $t1;
    usleep(200_000);    # 200ms
    my ( $t2, $i2 ) = read_proc_stat();
    return undef unless defined $t2;
    my $totald = $t2 - $t1;
    $totald = 1 if $totald <= 0;
    my $idled = $i2 - $i1;
    $idled = 0 if $idled < 0;
    my $usage = ( 1 - $idled / $totald ) * 100.0;
    return $usage;
}

# ── Get CPU usage ─────────────────────────────────────────────────────────────
my $cpu = cpu_usage_mpstat();
$cpu = cpu_usage_procstat() unless defined $cpu;
$cpu = 0.0                  unless defined $cpu;

# ── Build Pango ───────────────────────────────────────────────────────────────
my $pct_fmt = sprintf( "%.${decimals}f", $cpu );

my $LEFT =
  sprintf( "<span foreground='%s' background='%s' size='%s'> %s</span>",
    $SEG_BG, $BG_BAR, $SIZE_SEP, $SEP_LEFT );

my $MID = sprintf(
"<span background='%s'> <span foreground='%s' size='%s' rise='%s'>%s&#8202;</span> ",
    $SEG_BG, $FG_DARK, $SIZE_ICON, $RISE_ICON, $ICON );
$MID .=
  sprintf( "<span foreground='%s' size='%s' rise='%s'>%s%%</span>  </span>",
    $FG_TEXT, $SIZE_TEXT, $RISE_TEXT, $pct_fmt );

my $RIGHT =
  sprintf( "<span background='%s' foreground='%s' size='%s'>%s</span>",
    $SEG_BG, $BG_BAR, $SIZE_SEP, $SEP_RIGHT );

my $FULL  = ( $label // '' ) . $LEFT . $MID . $RIGHT;
my $SHORT = ( $label // '' )
  . sprintf(
"<span background='%s'> <span foreground='%s' size='%s'>%s</span> <span size='%s' rise='%s'>%s%%</span> </span>",
    $SEG_BG, $FG_DARK, $SIZE_ICON, $ICON, $SIZE_TEXT, $RISE_TEXT, $pct_fmt );

my $COLOR = $color_ok;
$COLOR = $color_warn if $cpu >= $t_warn;
$COLOR = $color_crit if $cpu >= $t_crit;

# ── Output 3 lines (i3blocks protocol) ───────────────────────────────────────
print "$FULL\n";
print "$SHORT\n";
print "$COLOR\n";
