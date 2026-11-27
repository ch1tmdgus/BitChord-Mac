package com.music.bitchord.desktop

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * macOS draws its three window buttons over the app's own content (the title bar is transparent
 * and the content runs underneath it), so there is no separate bar. This is the height of the strip
 * the buttons sit in — chrome that has to stay clear of them reserves this much at the top.
 *
 * Zero everywhere else. Expressed in the window's own points, so it is divided back out of the UI
 * zoom the way the sidebar's wordmark is.
 */
@Composable
internal fun macTitleBarInset(): Dp {
    if (!DesktopPlatform.isMac) return 0.dp
    val percent by DesktopUiScaleSettings.percent.collectAsState()
    return (MAC_TITLE_BAR_POINTS * 100f / percent).dp
}

private const val MAC_TITLE_BAR_POINTS = 28f
