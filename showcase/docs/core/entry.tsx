'use client'

import { createUniver, defaultTheme, LocaleType, merge } from '@univerjs/presets'
import { UniverDocsCorePreset } from '@univerjs/presets/preset-docs-core'
import docsCoreEnUS from '@univerjs/presets/preset-docs-core/locales/en-US'
import docsCoreZhCN from '@univerjs/presets/preset-docs-core/locales/zh-CN'
import { useTheme } from 'nextra-theme-docs'
import { useEffect, useRef } from 'react'
import { Preview } from '@/components/preview'
import { useCodeHighlight } from '@/hooks/use-code'

const code = `
import { createUniver, defaultTheme, LocaleType, merge } from '@univerjs/presets'

import { UniverDocsCorePreset } from '@univerjs/presets/preset-docs-core'
import docsCoreEnUS from '@univerjs/presets/preset-docs-core/locales/en-US'
import '@univerjs/presets/lib/styles/preset-docs-core.css'

const { univerAPI } = createUniver({
  locale: LocaleType.EN_US,
  locales: {
    [LocaleType.EN_US]: merge(
      {},
      docsCoreEnUS,
    ),
  },
  theme: defaultTheme,
  presets: [
    UniverDocsCorePreset(),
  ],
})

univerAPI.createUniverDoc({})
`

interface IDemoProps {
  lang: 'zh-CN' | 'en-US'
}

const localesMap = {
  'zh-CN': {
    name: 'ZH_CN',
    locale: LocaleType.ZH_CN,
    locales: merge(
      {},
      docsCoreZhCN,
    ),
  },
  'en-US': {
    name: 'EN_US',
    locale: LocaleType.EN_US,
    locales: merge(
      {},
      docsCoreEnUS,
    ),
  },
}

export default function Demo(props: IDemoProps) {
  const { lang } = props

  const containerRef = useRef<HTMLDivElement>(null!)

  const { theme } = useTheme()

  const { locale, locales } = localesMap[lang]

  useEffect(() => {
    const { univerAPI } = createUniver({
      darkMode: theme === 'dark',
      locale,
      locales: {
        [locale]: locales,
      },
      theme: defaultTheme,
      presets: [
        UniverDocsCorePreset({
          container: containerRef.current,
        }),
      ],
    })

    univerAPI.createUniverDoc({})

    return () => {
      univerAPI.dispose()
    }
  }, [])

  const codeWithHighlight = useCodeHighlight({
    code,
    lang,
  })

  return (
    <Preview ref={containerRef} code={codeWithHighlight} />
  )
}
