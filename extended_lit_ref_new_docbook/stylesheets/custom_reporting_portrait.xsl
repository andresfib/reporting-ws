<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:d="http://docbook.org/ns/docbook"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:ng="http://docbook.org/docbook-ng"
                exclude-result-prefixes="ng exsl d date"
                xmlns:meta="http://echa.europa.eu/schemas/reporting/metadata"
                version='1.0'>

    <xsl:import href="res:docbook/fo/docbook.xsl"/>

	<xsl:param name="ulink.show" select="0"></xsl:param>

    <xsl:param name="callout.extensions">1</xsl:param>

    <xsl:output method="xml" indent="no"/>

    <xsl:param name="fop1.extensions" select="1"/>
    <xsl:param name="fop.extensions">0</xsl:param>

    <xsl:param name="tablecolumns.extension">0</xsl:param>

    <xsl:param name="hyphenate">false</xsl:param>
    <xsl:param name="hyphenation-character">-</xsl:param>

    <xsl:param name="alignment">left</xsl:param>

    <xsl:param name="paper.type" select="'A4'"/>

    <xsl:param name="body.font.master">10</xsl:param>
    <xsl:param name="body.font.family" select="'Times-Roman'"/>
    <xsl:param name="title.font.family" select="'Times-Roman'"/>
    <xsl:param name="monospace.font.family" select="'Times-Roman'"/>
    <xsl:param name="symbol.font.family" select="'Arial Unicode MS'"/>
    <xsl:param name="dingbat.font.family" select="'Times-Roman'"/>
    <xsl:param name="callout.unicode.font" select="'Lucida Sans Unicode'"/>

    <xsl:param name="chapter.autolabel" select="1"/>
    <xsl:param name="section.autolabel" select="1"/>
    <xsl:param name="section.label.includes.component.label" select="1"/>
    <xsl:param name="section.autolabel.max.depth" select="5"/>

    <xsl:param name="toc.section.depth">5</xsl:param>
    <xsl:param name="generate.toc">
        book      toc,title
    </xsl:param>

    <xsl:template name="book.titlepage.verso"/>
    <xsl:template name="book.titlepage.before.verso"/>
    <xsl:template name="book.titlepage.separator"/>

    <!-- Remove certain sections from TOC for PPP-->
    <xsl:template match="*[@role = 'NotInToc']"  mode="toc" />

    <xsl:param name="local.l10n.xml" select="document('')"/>
    <l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
        <l:l10n language="en">
            <l:context name="title-numbered">
                <l:template name="chapter" text="%n.&#160;%t"/>
            </l:context>
        </l:l10n>
    </l:i18n>

    <xsl:variable name="front.cover.title" select="/d:book/d:info/d:title"/>
    <xsl:variable name="front.cover.subtitle" select="/d:book/d:info/d:subtitle"/>
    <xsl:variable name="front.cover.content" select="/d:book/d:info/d:cover/d:para"/>
    <xsl:template name="book.titlepage.recto">
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="$front.cover.title"/>
        <xsl:apply-templates mode="book.titlepage.recto.auto.mode" select="$front.cover.subtitle"/>
        <fo:block padding-top="2in">
            <xsl:apply-templates select="$front.cover.content"/>
        </fo:block>
    </xsl:template>

    <xsl:template match="processing-instruction('linebreak')">
        <fo:block/>
    </xsl:template>

    <xsl:template match="processing-instruction('hard-pagebreak')">
        <fo:block break-after='page'/>
    </xsl:template>

    <xsl:template match="d:chapter/*">
        <fo:block start-indent="0pt">
            <xsl:apply-imports/>
        </fo:block>
    </xsl:template>

    <xsl:template match="d:section">
        <fo:block start-indent="0pt">
            <xsl:apply-imports/>
        </fo:block>
    </xsl:template>

    <xsl:template match="d:formalpara/d:title">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:attribute-set name="xref.properties">
        <xsl:attribute name="color">#0000FF</xsl:attribute>
    </xsl:attribute-set>

    <xsl:template match="*[@role='title']">
        <fo:block font-size="15pt" font-weight="bold" padding-top="3pt" margin-top="3pt" text-align="center"
                  white-space-collapse="false">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="d:para[@role='align-right']">
        <fo:block text-align="right">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="d:para[@role='align-center']">
        <fo:block text-align="center">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="d:para[@role='align-justify']">
        <fo:block text-align="justify">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="d:para[@role='blockquote']">
        <fo:block space-before="1em" space-after="1em">
            <xsl:attribute name="start-indent">
                <xsl:value-of select="(count(ancestor::d:para[@role='blockquote']) + 1) * 3"/>
                <xsl:text>em</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[@role='bottom3pt']">
        <fo:block padding-top="0pt" margin-top="0pt" margin-bottom="3pt" white-space-collapse="true">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[@role='rule']">
        <fo:block>
            <fo:leader leader-length="100%" leader-pattern="rule"></fo:leader>
        </fo:block>
        <fo:block padding-top="5pt">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[@role='cover.rule']">
        <fo:block>
            <fo:leader leader-length="100%" leader-pattern="rule"></fo:leader>
        </fo:block>
        <fo:block padding-top="5pt">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[@role='cover.i6label']">
        <fo:inline font-weight="bold" font-size="11pt">
            <xsl:value-of select='text()'/>
            <xsl:text>: </xsl:text>
        </fo:inline>
    </xsl:template>

    <xsl:template match="*[@role='cover.i6content']">
        <fo:inline font-size="11pt">
            <xsl:value-of select='text()'/>
        </fo:inline>
    </xsl:template>

    <xsl:template match="*[@role='i6header1']">
        <fo:block font-size="16pt" font-weight="bold" padding-top="3pt" margin-top="3pt" text-align-last='justify'
                  white-space-collapse="false">
            <xsl:apply-templates/>
            <fo:leader leader-length.maximum="5pt"/>
            <fo:leader leader-pattern="rule" vertical-align="middle" color="grey"/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[@role='i6header2']">
        <fo:block font-size="15pt" font-weight="bold" padding-top="3pt" margin-top="3pt" text-align-last='justify'
                  white-space-collapse="false">
            <xsl:apply-templates/>
            <fo:leader leader-length.maximum="5pt"/>
            <fo:leader leader-pattern="rule" vertical-align="middle" color="grey"/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[@role='i6header3']">
        <fo:block font-size="14pt" font-weight="bold" padding-top="3pt" margin-top="3pt" text-align-last='justify'
                  white-space-collapse="false">
            <xsl:apply-templates/>
            <fo:leader leader-length.maximum="5pt"/>
            <fo:leader leader-pattern="rule" vertical-align="middle" color="grey"/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[@role='i6header4']">
        <fo:block font-size="13pt" font-weight="bold" padding-top="3pt" margin-top="3pt" text-align-last='justify'
                  white-space-collapse="false">
            <xsl:apply-templates/>
            <fo:leader leader-length.maximum="5pt"/>
            <fo:leader leader-pattern="rule" vertical-align="middle" color="grey"/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[@role='i6header5']">
        <fo:block font-size="12pt" font-weight="bold" padding-top="3pt" margin-top="3pt" text-align-last='justify'
                  white-space-collapse="false">
            <xsl:apply-templates/>
            <fo:leader leader-length.maximum="5pt"/>
            <fo:leader leader-pattern="rule" vertical-align="middle" color="grey"/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[@role='i6header5_nobold']">
        <fo:block font-size="12pt" padding-top="3pt" margin-top="3pt" text-align-last='justify'
                  white-space-collapse="false">
            <xsl:apply-templates/>
            <fo:leader leader-length.maximum="5pt"/>
            <fo:leader vertical-align="middle" color="grey"/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[@role='i6repeatable-header1']">
        <xsl:call-template name="i6label"/>
        <!--<fo:block font-size="16pt" font-weight="bold" padding-top="3pt" margin-top="3pt" white-space-collapse="false">-->
        <!--<xsl:apply-templates/>-->
        <!--</fo:block>-->
    </xsl:template>

    <xsl:template match="*[@role='i6repeatable-header2']">
        <xsl:call-template name="i6label"/>
        <!--<fo:block font-size="15pt" font-weight="bold" padding-top="3pt" margin-top="3pt" white-space-collapse="false">-->
        <!--<xsl:apply-templates/>-->
        <!--</fo:block>-->
    </xsl:template>

    <xsl:template match="*[@role='i6repeatable-header3']">
        <xsl:call-template name="i6label"/>
        <!--<fo:block font-size="14pt" font-weight="bold" padding-top="3pt" margin-top="3pt" white-space-collapse="false">-->
        <!--<xsl:apply-templates/>-->
        <!--</fo:block>-->
    </xsl:template>

    <xsl:template match="*[@role='i6repeatable-header4']">
        <xsl:call-template name="i6label"/>
        <!--<fo:block font-size="13pt" font-weight="bold" padding-top="3pt" margin-top="3pt" white-space-collapse="false">-->
        <!--<xsl:apply-templates/>-->
        <!--</fo:block>-->
    </xsl:template>

    <xsl:template match="*[@role='i6repeatable-header5']">
        <xsl:call-template name="i6label"/>
        <!--<fo:block font-size="12pt" font-weight="bold" padding-top="3pt" margin-top="3pt" white-space-collapse="false">-->
        <!--<xsl:apply-templates/>-->
        <!--</fo:block>-->
    </xsl:template>

    <xsl:template match="*[@role='i6repeatable-entry']">
        <fo:block border="0.5pt solid grey" padding="3pt" margin="0mm" keep-with-next.within-page="10"
                  keep-together.within-page="10">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[@role='i6label']">
        <xsl:call-template name="i6label"/>
    </xsl:template>

    <xsl:template name="i6label">
        <fo:block font-weight="bold" font-size="10pt" keep-with-next.within-page="always">
            <xsl:value-of select='text()'/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[@role='i6LiteralText']">
        <fo:block wrap-option="wrap" hyphenate="false" white-space-collapse="false" white-space-treatment="preserve"
                  linefeed-treatment="preserve" text-align="left">
            <xsl:value-of select='text()'/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[@role='cover.i6subtext']">
        <fo:inline font-size="16pt">
            <xsl:value-of select='text()'/>
        </fo:inline>
    </xsl:template>

    <!-- Handle tables-->
    <xsl:template name="make-html-table-columns">
        <xsl:param name="count" select="0"/>
        <xsl:param name="number" select="1"/>

        <xsl:choose>
            <xsl:when test="d:col|d:colgroup/d:col">
                <xsl:for-each select="d:col|d:colgroup/d:col">
                    <fo:table-column>
                        <xsl:attribute name="column-number">
                            <xsl:number from="d:table|d:informaltable" level="any" format="1"/>
                        </xsl:attribute>
                        <xsl:if test="@width">
                            <xsl:attribute name="column-width">
                                <xsl:choose>
                                    <xsl:when test="contains(@width, '%')">
                                        <xsl:value-of select="concat('proportional-column-width(',
		                                               substring-before(@width, '%'),
		                                               ')')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="@width"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </xsl:if>
                    </fo:table-column>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$fop.extensions != 0">
                <xsl:if test="$number &lt;= $count">
                    <fo:table-column column-number="{$number}"
                                     column-width="{6.5 div $count}in"/>
                    <xsl:call-template name="make-html-table-columns">
                        <xsl:with-param name="count" select="$count"/>
                        <xsl:with-param name="number" select="$number + 1"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Handle HEAD-WoutNo role -->
    <xsl:template match="*[@role='HEAD-WoutNo']">
        <fo:inline text-decoration="underline" font-weight="bold" font-size="small">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>

    <!-- Handle indent role-->
    <xsl:template match="*[@role='indent']">
        <fo:block space-before="0.4em" start-indent="14px">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

	<!-- Handle indent role 2-->
    <xsl:template match="*[@role='indent2']">
        <fo:block space-before="0.8em" start-indent="28px">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

	<!-- Handle indent role 3-->
    <xsl:template match="*[@role='indent3']">
        <fo:block space-before="1.2em" start-indent="42px">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <!-- Handle para medium-->
    <xsl:template match="*[@role='medium']">
        <fo:block font-size="12">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <!-- Handle para small -->
    <xsl:template match="*[@role='small']">
        <fo:block space-before="0em" start-indent="0px" font-size="9">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>


    <!-- Handle ignoreIfEmpty role-->
    <xsl:template match="*[@role='ignoreIfEmpty']">
        <xsl:if test="normalize-space(./text()) != ''">
            <fo:block>
                <xsl:apply-templates/>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <!-- Handle color attribute-->
    <xsl:template match="*[@color]">
        <xsl:variable name="color" select="@color"/>
        <xsl:element name="fo:inline">
            <xsl:attribute name="color">
                <xsl:value-of select="$color"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Handle style attribute for background color-->
    <xsl:template match="*[@style]">
        <xsl:variable name="style" select="@style"/>
        <xsl:choose>
            <xsl:when test="contains($style,'background-color:')">
                <xsl:element name="fo:inline">
                    <xsl:attribute name="background-color">
                        <xsl:value-of select="substring($style,18,7)"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:param name="left.header.text" select="/d:book/d:info/meta:params/meta:param[@meta:name='left.header.text']"/>
    <xsl:param name="central.header.text"
               select="/d:book/d:info/meta:params/meta:param[@meta:name='central.header.text']"/>
    <xsl:param name="right.header.text" select="/d:book/d:info/meta:params/meta:param[@meta:name='right.header.text']"/>
    <xsl:param name="header.image.filename" select="''"/>
    <xsl:param name="header.column.widths">1 4 1</xsl:param>

    <xsl:template name="header.content">
        <xsl:param name="pageclass" select="''"/>
        <xsl:param name="sequence" select="''"/>
        <xsl:param name="position" select="''"/>
        <xsl:param name="gentext-key" select="''"/>

        <fo:block>
            <!-- sequence can be odd, even, first, blank -->
            <!-- position can be left, center, right -->
            <xsl:choose>

                <xsl:when test="$position = 'left'">
                    <xsl:choose>
                        <xsl:when test="$header.image.filename != ''">
                            <fo:external-graphic content-height="1cm">
                                <xsl:attribute name="src">
                                    <xsl:call-template name="fo-external-image">
                                        <xsl:with-param name="filename" select="$header.image.filename"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </fo:external-graphic>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:value-of select="$left.header.text"/>
                </xsl:when>

                <xsl:when test="$position='center'">
                    <fo:inline>
                        <xsl:value-of select="$central.header.text"/>
                    </fo:inline>
                </xsl:when>

                <xsl:when test="$position = 'right'">
                    <xsl:value-of select="$right.header.text"/>
                </xsl:when>

            </xsl:choose>
        </fo:block>
    </xsl:template>


    <xsl:param name="left.footer.text" select="/d:book/d:info/meta:params/meta:param[@meta:name='left.footer.text']" />
    <xsl:param name="central.footer.text" select="/d:book/d:info/meta:params/meta:param[@meta:name='central.footer.text']" />
    <xsl:param name="right.footer.text" select="/d:book/d:info/meta:params/meta:param[@meta:name='right.footer.text']" />
    <xsl:param name="footer.column.widths">2 2 1</xsl:param>

    <!-- Report footer -->
    <xsl:template name="footer.content">
        <xsl:param name="pageclass" select="''" />
        <xsl:param name="sequence" select="''" />
        <xsl:param name="position" select="''" />
        <xsl:param name="gentext-key" select="''" />

        <fo:block>
            <!-- sequence can be odd, even, first, blank -->
            <!-- position can be left, center, right -->
            <xsl:choose>

                <xsl:when test="$pageclass = 'titlepage'">
                    <!-- nop; no footer on title pages -->
                </xsl:when>

                <xsl:when test="$position = 'left'">
                    <xsl:value-of select="$left.footer.text" />
                </xsl:when>

                <xsl:when test="$position='center'">
                    <fo:block text-align="left">
                        <xsl:value-of select="$central.footer.text" />
                    </fo:block>
                </xsl:when>

                <xsl:when test="$position = 'right'">
                    <xsl:value-of select="$right.footer.text" />
                    <fo:page-number />
                </xsl:when>

            </xsl:choose>
        </fo:block>
    </xsl:template>

    <xsl:param name="draft.mode" select="/d:book/d:info/meta:waterMarkParams/meta:param[@meta:name='draft.mode']" />
    <xsl:param name="draft.watermark.image" select="/d:book/d:info/meta:waterMarkParams/meta:param[@meta:name='draft.watermark.image']" />
    <xsl:template name="draft.text">
    </xsl:template>
    
    <xsl:param name="l10n.gentext.language" select="/d:book/d:info/meta:localizationParam/meta:param[@meta:name='locale']"/>

</xsl:stylesheet>
